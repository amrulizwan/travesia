import nodemailer from 'nodemailer';

const transporter = nodemailer.createTransport({
  host: 'smtp.gmail.com',
  port: 465,
  secure: true,
  auth: {
    user: process.env.GMAIL_USER,
    pass: process.env.GMAIL_PASS,
  },
  tls: {
    rejectUnauthorized: false,
  },
});

const sendResetOTP = async (to, subject, otp) => {
  try {
    const mailOptions = {
      from: process.env.GMAIL_USER,
      to,
      subject,
      html: `
            <div style="font-family: Arial, sans-serif; text-align: center; padding: 20px; background-color: #f9f9f9;">
            <div style="max-width: 500px; margin: auto; background: #ffffff; padding: 20px; border-radius: 8px; box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);">
            
            <!-- Tambahkan Gambar di Tengah -->
            <img src="http://drive.google.com/uc?export=view&id=1yDxeI3hs5V_8HVAHHN00roBkTutPM9Ij" alt="Reset Password" 
                style="max-width: 100px; margin: 20px auto; display: block;">
            
            <h2 style="color: #333;">Reset Password OTP</h2>
            <p style="color: #555;">Gunakan kode OTP di bawah ini untuk mereset password Anda:</p>
            
            <!-- OTP Box -->
            <div style="background: #f5f5f5; padding: 15px; margin: 20px auto; border-radius: 5px; font-size: 24px; letter-spacing: 5px; font-weight: bold; color: #333; max-width: 200px;">
              ${otp}
            </div>

            <p style="margin-top: 20px; font-size: 14px; color: #777;">
            Jika Anda tidak meminta reset password, abaikan email ini.
            </p>

            <p style="margin-top: 20px; font-size: 14px; color: #777;">
            Kode OTP ini akan kadaluarsa dalam 5 menit.
            </p>
        </div>
        </div>
      `,
    };

    await transporter.sendMail(mailOptions);
    console.log('Email OTP sent successfully');
  } catch (error) {
    console.error('Error sending OTP email:', error);
  }
};

export { sendResetOTP };
