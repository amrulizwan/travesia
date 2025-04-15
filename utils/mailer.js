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

const sendMail = async (to, subject, verificationLink) => {
  try {
    const mailOptions = {
      from: process.env.GMAIL_USER,
      to,
      subject,
      html: `
            <div style="font-family: Arial, sans-serif; text-align: center; padding: 20px; background-color: #f9f9f9;">
            <div style="max-width: 500px; margin: auto; background: #ffffff; padding: 20px; border-radius: 8px; box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);">
            
            <!-- Tambahkan Gambar di Tengah -->
            <img src="http://drive.google.com/uc?export=view&id=1yDxeI3hs5V_8HVAHHN00roBkTutPM9Ij" alt="Verify Email" 
                style="max-width: 100px; margin: 20px auto; display: block;">
            
            <h2 style="color: #333;">Verify Your Email</h2>
            <p style="color: #555;">Click the button below to verify your email address.</p>
            
            <!-- Tombol Verifikasi -->
            <a href="${verificationLink}" 
            style="display: inline-block; padding: 12px 25px; margin-top: 10px; font-size: 16px; color: #fff; 
                    background: #1F7CFF; text-decoration: none; border-radius: 5px;">
            Verify Email
            </a>

            <p style="margin-top: 20px; font-size: 14px; color: #777;">
            If you did not request this, please ignore this email.
            </p>

            <p style="margin-top: 20px; font-size: 14px; color: #777;">
            If button does not work, copy and paste the link below into your browser:
            ${verificationLink}
            </p>
        </div>
        </div>
      `,
    };

    await transporter.sendMail(mailOptions);
    console.log('Email sent successfully');
  } catch (error) {
    console.error('Error sending email:', error);
  }
};

const sendResetPasswordLink = async (to, subject, resetLink) => {
  try {
    const mailOptions = {
      from: process.env.GMAIL_USER,
      to,
      subject,
      html: `
            <div style="font-family: Arial, sans-serif; text-align: center; padding: 20px; background-color: #f9f9f9;">
            <div style="max-width: 500px; margin: auto; background: #ffffff; padding: 20px; border-radius: 8px; box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);">
            
            <!-- Tambahkan Gambar di Tengah -->
            <img src="http://drive.google.com/uc?export=view&id=1yDxeI3hs5V_8HVAHHN00roBkTutPM9Ij" alt="Verify Email" 
                style="max-width: 100px; margin: 20px auto; display: block;">
            
            <h2 style="color: #333;">Reset Your Password</h2>
            <p style="color: #555;">Click the button below to reset your password.</p>
            
            <!-- Tombol Verifikasi -->
            <a href="${resetLink}" 
            style="display: inline-block; padding: 12px 25px; margin-top: 10px; font-size: 16px; color: #fff; 
                    background:rgb(255, 177, 31); text-decoration: none; border-radius: 5px;">
            Reset Password
            </a>

            <p style="margin-top: 20px; font-size: 14px; color: #777;">
            If you did not request this, please ignore this email.
            </p>

            <p style="margin-top: 20px; font-size: 14px; color: #777;">
            If button does not work, copy and paste the link below into your browser:
            ${resetLink}
            </p>
        </div>
        </div>
      `,
    };

    await transporter.sendMail(mailOptions);
    console.log('Email sent successfully');
  } catch (error) {
    console.error('Error sending email:', error);
  }
};

export { sendMail, sendResetPasswordLink };
