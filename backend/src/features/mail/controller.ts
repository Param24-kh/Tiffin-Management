import nodemailer from 'nodemailer';
import { Request, Response } from 'express';
import dotenv from "dotenv";
dotenv.config();

export async function sendWelcomeEmail(email: string, subject: string, passkey: string, centerId?: string) {
    try {
        // Set up transporter with Gmail SMTP settings
        let transporter = nodemailer.createTransport({
            service: "gmail",
            auth: {
                user: 'icpmaheshwari2016@gmail.com', // Your Gmail address
                pass: 'ncfl hzzn lsud ymhi'  // Your Gmail app password (for added security)
            }
        });

        // Generate email content
        const textContent = `Welcome! Your account has been created. Here are your credentials:\n\nPasskey: ${passkey}${centerId ? `\nCenter ID: ${centerId}` : ""}`;
        const htmlContent = `<b>Welcome! Your account has been created.</b><br><br>Your credentials are:<br>Passkey: ${passkey}${centerId ? `<br>Center ID: ${centerId}` : ""}`;

        let message: nodemailer.SendMailOptions = {
            from: `"No Reply" <${process.env.GMAIL_USER}>`,
            to: email,
            subject: subject,
            text: textContent,
            html: htmlContent
        };

        let info = await transporter.sendMail(message);
        console.log("Message sent: %s", info.messageId);
    } catch (error) {
        console.error("Error sending email:", error);
    }
}
