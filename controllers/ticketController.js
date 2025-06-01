import mongoose from 'mongoose';
import Ticket from '../models/Ticket.js';
import Wisata from '../models/Wisata.js';
import { snap as midtransSnap } from '../utils/midtrans.js'; // Import Midtrans Snap instance
import { v4 as uuidv4 } from 'uuid'; // For generating unique order IDs

// Function 1: Create Transaction (Initiate Ticket Purchase)
export const createTransaction = async (req, res) => {
  try {
    const { wisataId, quantity } = req.body; // quantity: { dewasa: Number, anakAnak: Number }
    const userId = req.user._id; // Assuming 'protect' middleware attaches user

    if (!mongoose.Types.ObjectId.isValid(wisataId)) {
      return res.status(400).json({ message: 'Invalid Wisata ID format' });
    }

    const wisata = await Wisata.findById(wisataId);
    if (!wisata) {
      return res.status(404).json({ message: 'Wisata not found' });
    }

    if (!quantity || (quantity.dewasa === undefined && quantity.anakAnak === undefined)) {
        return res.status(400).json({ message: 'Quantity for dewasa or anakAnak must be provided' });
    }

    const numDewasa = Number(quantity.dewasa) || 0;
    const numAnak = Number(quantity.anakAnak) || 0;

    if (numDewasa < 0 || numAnak < 0) {
        return res.status(400).json({ message: 'Quantity cannot be negative' });
    }
    if (numDewasa === 0 && numAnak === 0) {
        return res.status(400).json({ message: 'At least one ticket (dewasa or anakAnak) must be purchased' });
    }

    const totalPrice = (numDewasa * wisata.hargaTiket.dewasa) + (numAnak * wisata.hargaTiket.anakAnak);
    if (totalPrice <= 0) {
         return res.status(400).json({ message: 'Total price must be greater than zero. Check ticket prices for Wisata.'});
    }

    const orderId = `TICKET-${uuidv4()}`;

    // Create a new ticket document in 'pending' state
    const newTicket = new Ticket({
      user: userId,
      wisata: wisataId,
      orderId,
      quantity: { dewasa: numDewasa, anakAnak: numAnak },
      totalPrice,
      paymentStatus: 'pending',
    });

    // Midtrans transaction parameters
    const midtransParams = {
      transaction_details: {
        order_id: orderId,
        gross_amount: totalPrice,
      },
      item_details: [],
      customer_details: {
        first_name: req.user.nama, // Assuming user name is 'nama'
        email: req.user.email,
        phone: req.user.telepon || undefined, // Optional
      },
      // Optional: expiry, page_redirect_url, etc.
    };

    if (numDewasa > 0) {
        midtransParams.item_details.push({
            id: `${wisataId}-dewasa`,
            price: wisata.hargaTiket.dewasa,
            quantity: numDewasa,
            name: `${wisata.nama} - Tiket Dewasa`,
        });
    }
    if (numAnak > 0) {
        midtransParams.item_details.push({
            id: `${wisataId}-anak`,
            price: wisata.hargaTiket.anakAnak,
            quantity: numAnak,
            name: `${wisata.nama} - Tiket Anak-Anak`,
        });
    }

    const snapToken = await midtransSnap.createTransactionToken(midtransParams);

    newTicket.snapToken = snapToken;
    // newTicket.transactionId = transaction.transaction_id; // transaction_id is usually available after payment success from notification
    await newTicket.save();

    res.status(201).json({
      message: 'Transaction created successfully. Please proceed to payment.',
      orderId,
      snapToken,
      ticketId: newTicket._id
    });

  } catch (error) {
    console.error('Create transaction error:', error);
    // Differentiate Midtrans errors if possible
    if (error.isMidtransError) {
         return res.status(500).json({ message: 'Midtrans API error', error: error.message, details: error.ApiResponse });
    }
    res.status(500).json({ message: 'Server error while creating transaction', error: error.message });
  }
};

// Function 2: Handle Midtrans Payment Notification
export const handleMidtransNotification = async (req, res) => {
  try {
    const notificationJson = req.body;
    // Use Midtrans library to verify the notification signature for security
    // This is a crucial step in a production environment.
    // For now, we'll process based on the notification directly, but add a TODO.
    // TODO: Implement Midtrans signature verification:
    // const statusResponse = await midtransSnap.transaction.notification(notificationJson);
    // const orderId = statusResponse.order_id;
    // const transactionStatus = statusResponse.transaction_status;
    // const fraudStatus = statusResponse.fraud_status;
    // ... proceed with verified data ...

    const orderId = notificationJson.order_id;
    const transactionStatus = notificationJson.transaction_status;
    const fraudStatus = notificationJson.fraud_status;
    const paymentType = notificationJson.payment_type;
    const transactionId = notificationJson.transaction_id;

    const ticket = await Ticket.findOne({ orderId: orderId });
    if (!ticket) {
      return res.status(404).json({ message: 'Ticket with this orderId not found.' });
    }

    // Idempotency: If already processed, just return success
    if (ticket.paymentStatus === 'success' && transactionStatus === 'capture' && fraudStatus === 'accept') {
        return res.status(200).json({ message: 'Notification already processed for successful payment.' });
    }
    if (ticket.paymentStatus === 'failed' && (transactionStatus === 'deny' || transactionStatus === 'expire' || transactionStatus === 'cancel')) {
        return res.status(200).json({ message: 'Notification already processed for failed/expired payment.' });
    }


    let newPaymentStatus = ticket.paymentStatus;

    if (transactionStatus == 'capture') {
      if (fraudStatus == 'accept') {
        newPaymentStatus = 'success';
        ticket.paidAt = new Date(notificationJson.settlement_time || Date.now());
      } else if (fraudStatus == 'challenge') {
        // TODO: Handle 'challenge' status (e.g., mark as 'pending_review')
        newPaymentStatus = 'pending'; // Or a custom status like 'review'
        console.log(`Payment for orderId ${orderId} is challenged by FDS. Needs manual review.`);
      }
    } else if (transactionStatus == 'settlement') { // 'settlement' also means success
      newPaymentStatus = 'success';
      ticket.paidAt = new Date(notificationJson.settlement_time || Date.now());
    } else if (transactionStatus == 'pending') {
      newPaymentStatus = 'pending';
    } else if (transactionStatus == 'deny') {
      newPaymentStatus = 'failed';
    } else if (transactionStatus == 'expire') {
      newPaymentStatus = 'expired';
    } else if (transactionStatus == 'cancel') {
      newPaymentStatus = 'cancelled';
    }

    ticket.paymentStatus = newPaymentStatus;
    ticket.paymentMethod = paymentType;
    ticket.transactionId = transactionId; // Update with the actual transaction_id from Midtrans

    // Store the raw notification for auditing if needed
    // ticket.midtransNotificationPayload = notificationJson;

    await ticket.save();

    console.log(`Payment status for orderId ${orderId} updated to ${newPaymentStatus}.`);
    // Respond to Midtrans with 200 OK
    res.status(200).json({ message: 'Notification received and processed successfully.' });

  } catch (error) {
    console.error('Midtrans notification handling error:', error);
    res.status(500).json({ message: 'Server error while handling Midtrans notification', error: error.message });
  }
};

// Function 3: Get User's Tickets
export const getUserTickets = async (req, res) => {
  try {
    const userId = req.user._id;
    const tickets = await Ticket.find({ user: userId })
      .populate('wisata', 'nama lokasi hargaTiket') // Populate with selected Wisata details
      .sort({ createdAt: -1 });

    if (!tickets.length) {
      return res.status(404).json({ message: 'No tickets found for this user.' });
    }
    res.status(200).json({ data: tickets });
  } catch (error) {
    console.error('Get user tickets error:', error);
    res.status(500).json({ message: 'Server error while fetching user tickets', error: error.message });
  }
};

// Function 4: Get Sales by Wisata (for Admin/Pengelola)
export const getSalesByWisata = async (req, res) => {
    try {
        const { wisataId } = req.params;

        if (!mongoose.Types.ObjectId.isValid(wisataId)) {
            return res.status(400).json({ message: 'Invalid Wisata ID format' });
        }

        const wisata = await Wisata.findById(wisataId);
        if (!wisata) {
            return res.status(404).json({ message: 'Wisata not found' });
        }

        // Authorization: Only admin or the pengelola of this wisata can access
        if (req.user.role !== 'admin' && wisata.pengelola.toString() !== req.user._id.toString()) {
            return res.status(403).json({ message: 'Access denied. You are not the manager of this Wisata or an Admin.' });
        }

        const tickets = await Ticket.find({ wisata: wisataId, paymentStatus: 'success' })
            .populate('user', 'nama email') // Populate with selected user details
            .sort({ createdAt: -1 });

        if (!tickets.length) {
            return res.status(404).json({ message: 'No successful sales found for this Wisata yet.' });
        }

        // Calculate total revenue for this wisata from successful tickets
        const totalRevenue = tickets.reduce((acc, ticket) => acc + ticket.totalPrice, 0);
        const totalTicketsSold = tickets.reduce((acc, ticket) => acc + (ticket.quantity.dewasa || 0) + (ticket.quantity.anakAnak || 0), 0);


        res.status(200).json({
            message: `Sales data for ${wisata.nama}`,
            totalRevenue,
            totalTicketsSold,
            count: tickets.length,
            data: tickets,
        });

    } catch (error) {
        console.error('Get sales by wisata error:', error);
        res.status(500).json({ message: 'Server error while fetching sales data', error: error.message });
    }
};
