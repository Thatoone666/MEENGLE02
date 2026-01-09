import nodemailer from 'nodemailer';

const transporter = nodemailer.createTransport({
  service: process.env.EMAIL_SERVICE || 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD
  }
});

export const sendVerificationEmail = async (email, token) => {
  try {
    const verificationLink = `${process.env.FRONTEND_URL}/verify-email?token=${token}`;

    const mailOptions = {
      from: process.env.EMAIL_FROM || 'noreply@meengle.app',
      to: email,
      subject: 'Verify Your Meengle Account',
      html: `
        <h2>Welcome to Meengle!</h2>
        <p>Please verify your email address to complete your account setup.</p>
        <p>
          <a href="${verificationLink}" style="background: #FF6B6B; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block;">
            Verify Email
          </a>
        </p>
        <p>Or copy this link: ${verificationLink}</p>
        <p>This link expires in 24 hours.</p>
      `
    };

    await transporter.sendMail(mailOptions);
    return { success: true };
  } catch (error) {
    console.error('Send verification email error:', error);
    return { success: false, error: error.message };
  }
};

export const sendPasswordResetEmail = async (email, token) => {
  try {
    const resetLink = `${process.env.FRONTEND_URL}/reset-password?token=${token}`;

    const mailOptions = {
      from: process.env.EMAIL_FROM || 'noreply@meengle.app',
      to: email,
      subject: 'Reset Your Meengle Password',
      html: `
        <h2>Password Reset Request</h2>
        <p>Click the link below to reset your password:</p>
        <p>
          <a href="${resetLink}" style="background: #FF6B6B; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block;">
            Reset Password
          </a>
        </p>
        <p>Or copy this link: ${resetLink}</p>
        <p>This link expires in 1 hour.</p>
        <p>If you didn't request this, ignore this email.</p>
      `
    };

    await transporter.sendMail(mailOptions);
    return { success: true };
  } catch (error) {
    console.error('Send reset email error:', error);
    return { success: false, error: error.message };
  }
};

export const sendWelcomeEmail = async (email, name) => {
  try {
    const mailOptions = {
      from: process.env.EMAIL_FROM || 'noreply@meengle.app',
      to: email,
      subject: 'Welcome to Meengle!',
      html: `
        <h2>Welcome, ${name}!</h2>
        <p>Your account is ready to go. Start connecting with people nearby!</p>
        <p>Get started by:</p>
        <ul>
          <li>Completing your profile</li>
          <li>Adding photos</li>
          <li>Setting up your preferences</li>
          <li>Finding matches</li>
        </ul>
        <p>Questions? Check our FAQ or contact support.</p>
      `
    };

    await transporter.sendMail(mailOptions);
    return { success: true };
  } catch (error) {
    console.error('Send welcome email error:', error);
    return { success: false, error: error.message };
  }
};

export const sendReportNotificationEmail = async (adminEmail, reportData) => {
  try {
    const mailOptions = {
      from: process.env.EMAIL_FROM || 'noreply@meengle.app',
      to: adminEmail,
      subject: `[URGENT] New Fraud Report - Risk Score ${reportData.riskScore}`,
      html: `
        <h2>New Fraud Report</h2>
        <p><strong>Reported User:</strong> ${reportData.reportedUserId}</p>
        <p><strong>Reason:</strong> ${reportData.reason}</p>
        <p><strong>Risk Score:</strong> ${reportData.riskScore}/10</p>
        <p><strong>Details:</strong> ${reportData.details}</p>
        <p>
          <a href="${process.env.ADMIN_URL}/reports" style="background: #FF6B6B; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block;">
            Review Report
          </a>
        </p>
      `
    };

    await transporter.sendMail(mailOptions);
    return { success: true };
  } catch (error) {
    console.error('Send report email error:', error);
    return { success: false, error: error.message };
  }
};

export const sendPaymentConfirmationEmail = async (email, paymentData) => {
  try {
    const mailOptions = {
      from: process.env.EMAIL_FROM || 'noreply@meengle.app',
      to: email,
      subject: 'Payment Confirmed',
      html: `
        <h2>Payment Confirmed</h2>
        <p><strong>Amount:</strong> R${paymentData.amount}</p>
        <p><strong>Tier:</strong> ${paymentData.tier}</p>
        <p><strong>Transaction ID:</strong> ${paymentData.transactionId}</p>
        <p><strong>Date:</strong> ${new Date(paymentData.date).toLocaleDateString()}</p>
        <p>Thank you for your subscription!</p>
      `
    };

    await transporter.sendMail(mailOptions);
    return { success: true };
  } catch (error) {
    console.error('Send payment email error:', error);
    return { success: false, error: error.message };
  }
};

export default transporter;
