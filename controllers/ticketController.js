import mongoose from 'mongoose';
import Ticket from '../models/Ticket.js';
import Wisata from '../models/Wisata.js';
import { snap as midtransSnap } from '../utils/midtrans.js'; // Import Midtrans Snap instance
import { v4 as uuidv4 } from 'uuid'; // For generating unique order IDs

// Function 1: Create Transaction (Initiate Ticket Purchase) - MODIFIED
export const createTransaction = async (req, res) => {
  try {
    // Expects: { wisataId: String, itemsToPurchase: [{ ticketTypeId: String, quantity: Number }] }
    const { wisataId, itemsToPurchase } = req.body;
    const userId = req.user._id; // Assuming 'protect' middleware attaches user

    if (!mongoose.Types.ObjectId.isValid(wisataId)) {
      return res.status(400).json({ message: 'Invalid Wisata ID format' });
    }

    const wisata = await Wisata.findById(wisataId);
    if (!wisata) {
      return res.status(404).json({ message: 'Wisata not found' });
    }
    if (!wisata.ticketTypes || wisata.ticketTypes.length === 0) {
        return res.status(400).json({ message: 'This Wisata currently has no ticket types defined.' });
    }

    if (!Array.isArray(itemsToPurchase) || itemsToPurchase.length === 0) {
        return res.status(400).json({ message: 'itemsToPurchase array must be provided and cannot be empty.' });
    }

    let calculatedTotalPrice = 0;
    const purchasedItemsDetails = []; // For storing in Ticket model
    const midtransItemDetails = [];   // For Midtrans API

    for (const item of itemsToPurchase) {
      if (!item.ticketTypeId || !mongoose.Types.ObjectId.isValid(item.ticketTypeId)) {
          return res.status(400).json({ message: `Invalid ticketTypeId format: ${item.ticketTypeId}`});
      }
      const ticketType = wisata.ticketTypes.id(item.ticketTypeId); // Find subdocument by _id
      if (!ticketType) {
        return res.status(400).json({ message: `Ticket type with ID ${item.ticketTypeId} not found for this Wisata.` });
      }
      if (!Number.isInteger(item.quantity) || item.quantity <= 0) {
        return res.status(400).json({ message: `Invalid quantity for ticket type ${ticketType.name}. Must be a positive integer.`});
      }

      calculatedTotalPrice += ticketType.price * item.quantity;
      purchasedItemsDetails.push({
        ticketTypeId: ticketType._id, // Store the actual ID from Wisata's ticketTypes
        name: ticketType.name,
        priceAtPurchase: ticketType.price,
        quantity: item.quantity,
        description: ticketType.description,
      });
      midtransItemDetails.push({
        id: ticketType._id.toString(), // Use ticketType._id as a unique identifier for Midtrans item
        price: ticketType.price,
        quantity: item.quantity,
        name: `${wisata.nama} - ${ticketType.name}`, // Construct a descriptive name
      });
    }

    if (calculatedTotalPrice <= 0) {
        return res.status(400).json({ message: 'Total price must be greater than zero. Check item quantities and ticket prices.' });
    }

    const orderId = `TICKET-${uuidv4()}`;

    const newTicket = new Ticket({
      user: userId,
      wisata: wisataId,
      orderId,
      purchasedItems: purchasedItemsDetails, // Use the new structure
      totalPrice: calculatedTotalPrice,
      paymentStatus: 'pending',
    });

    const midtransParams = {
      transaction_details: {
        order_id: orderId,
        gross_amount: calculatedTotalPrice,
      },
      item_details: midtransItemDetails, // Use the new structure
      customer_details: {
        first_name: req.user.nama,
        email: req.user.email,
        phone: req.user.telepon || undefined,
      },
    };

    const snapToken = await midtransSnap.createTransactionToken(midtransParams);

    newTicket.snapToken = snapToken;
    await newTicket.save();

    res.status(201).json({
      message: 'Transaction created successfully. Please proceed to payment.',
      orderId,
      snapToken,
      ticketId: newTicket._id,
      purchasedItems: newTicket.purchasedItems,
      totalPrice: newTicket.totalPrice
    });

  } catch (error) {
    console.error('Create transaction error:', error);
    if (error.isMidtransError) { // Check if it's a Midtrans specific error
         return res.status(500).json({ message: 'Midtrans API error', error: error.message, details: error.ApiResponse });
    }
    res.status(500).json({ message: 'Server error while creating transaction', error: error.message });
  }
};

// Function 2: Handle Midtrans Payment Notification - No direct changes needed by this task's schema modification
// but ensure it correctly updates based on orderId.
export const handleMidtransNotification = async (req, res) => {
  try {
    const notificationJson = req.body;
    // TODO: Implement Midtrans signature verification
    // const statusResponse = await midtransSnap.transaction.notification(notificationJson); // Secure way
    // For now, direct use (less secure for webhook testing without proper tunnel/verification)
    const orderId = notificationJson.order_id;
    const transactionStatus = notificationJson.transaction_status;
    const fraudStatus = notificationJson.fraud_status;
    const paymentType = notificationJson.payment_type;
    const transactionId = notificationJson.transaction_id; // Midtrans's transaction_id

    const ticket = await Ticket.findOne({ orderId: orderId });
    if (!ticket) {
      return res.status(404).json({ message: 'Ticket with this orderId not found.' });
    }

    // Idempotency checks
    if (ticket.paymentStatus === 'success' && transactionStatus === 'capture' && fraudStatus === 'accept') {
        return res.status(200).json({ message: 'Notification already processed for successful payment.' });
    }
    // Add more idempotency checks if needed for other statuses

    let newPaymentStatus = ticket.paymentStatus;

    if (transactionStatus == 'capture') {
      if (fraudStatus == 'accept') {
        newPaymentStatus = 'success';
        ticket.paidAt = new Date(notificationJson.settlement_time || Date.now());
      } else if (fraudStatus == 'challenge') {
        newPaymentStatus = 'pending'; // Or a custom status like 'review'
        console.log(`Payment for orderId ${orderId} is challenged by FDS. Needs manual review.`);
      }
    } else if (transactionStatus == 'settlement') {
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
    ticket.transactionId = transactionId; // Store Midtrans transaction_id

    await ticket.save();
    console.log(`Payment status for orderId ${orderId} updated to ${newPaymentStatus}.`);
    res.status(200).json({ message: 'Notification received and processed successfully.' });

  } catch (error) {
    console.error('Midtrans notification handling error:', error);
    res.status(500).json({ message: 'Server error while handling Midtrans notification', error: error.message });
  }
};

// Function 3: Get User's Tickets - Adjusted to reflect new schema if needed for display
export const getUserTickets = async (req, res) => {
  try {
    const userId = req.user._id;
    const tickets = await Ticket.find({ user: userId })
      .populate('wisata', 'nama lokasi ticketTypes') // Populate with Wisata name, location, and its available ticketTypes
      .sort({ createdAt: -1 });

    if (!tickets.length) {
      return res.status(200).json({ message: 'No tickets found for this user.', data: [] });
    }
    res.status(200).json({ data: tickets });
  } catch (error) {
    console.error('Get user tickets error:', error);
    res.status(500).json({ message: 'Server error while fetching user tickets', error: error.message });
  }
};

// Function 4: Get Sales by Wisata (for Admin/Pengelola) - Adjusted for new purchasedItems structure
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

        if (req.user.role !== 'admin' && (!wisata.pengelola || wisata.pengelola.toString() !== req.user._id.toString())) {
            return res.status(403).json({ message: 'Access denied. You are not the manager of this Wisata or an Admin.' });
        }

        const tickets = await Ticket.find({ wisata: wisataId, paymentStatus: 'success' })
            .populate('user', 'nama email')
            .sort({ createdAt: -1 });

        if (!tickets.length) {
            return res.status(200).json({
                message: `No successful sales found for ${wisata.nama} yet.`,
                totalRevenue: 0,
                totalTicketsSold: 0,
                count: 0,
                data: []
            });
        }

        const totalRevenue = tickets.reduce((acc, ticket) => acc + ticket.totalPrice, 0);

        let totalTicketsSold = 0;
        tickets.forEach(ticket => {
            ticket.purchasedItems.forEach(item => {
                totalTicketsSold += item.quantity;
            });
        });

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
