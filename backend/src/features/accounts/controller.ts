import { getCollection, mongoErrorHander } from "../../db/db";
import { Router, Request, Response } from "express";
import {IAccount, ICenterAccount,IPasskey} from "./accountModel";
import { generateJWTToken, generatePasskey } from "./ctrl_func";
import { sendWelcomeEmail } from "../mail/controller";
/*
export const createCenter = async (req: Request, res: Response) => {
try{    
    const{
        name,
        phoneNumber,
        email,
        address,
        deliveryAddress,
        auth,
    } = req.body;
    getCollection("TiffinCenter", null).then((coll) => {
    const testCenter: IAccount = {
        centerId: generatePasskey("TMS"),
        name: name || "TMS_Center",
        phoneNumber: phoneNumber || "",
        email:  email || "",
        auth:{
            username: auth.username,
            password:auth.password,
            expiresAt: new Date(new Date().setFullYear(2025)).toISOString()
        },
        address:  address || "",
        deliveryAddress: deliveryAddress || ""
    };
    console.log(testCenter)
    coll.createIndex({ "centerId": 1 },
        { unique: true }).then((e) => 
            { console.log("created index") })
    coll.insertOne(testCenter).then(() => { console.log("inserted") })});
    return res.status(201).json({
        success: true,
        message: "Tiffin center created successfully"
    });
}catch(error : any){
    console.error("Error in createHospital", error);
    return res.status(500).json({
        success: false,
        message: "Internal Server Error"
    });}
}
*/

export const logIn = async (req: Request, res: Response) => {
    try{
        const {email, passkey} = req.body;
        let chechingpasskey = passkey.toString();
        const checkLogin = chechingpasskey.substring(0,3);
        if(checkLogin === "tms"){
            const serviceProviderColl = await getCollection<ICenterAccount>("ServiceProvider", null);
            const serviceProviderResult = await serviceProviderColl.findOne({
                "auth.email": email,
                "auth.passkey": passkey
            })
            if(serviceProviderResult){
                const token = generateJWTToken(serviceProviderResult.centerId, serviceProviderResult.auth.passkey);
                return res.status(200).json({
                    success: true,
                    message: "Login Successful",
                    token: token
                });
            }else{
                return res.status(401).json({
                    success: false,
                    message: "Invalid Credentials"
                });
            }
        }else{
            const centerColl = await getCollection<IAccount>("User", null);
            const userResult = await centerColl.findOne({
                "auth.email": email,
                "auth.passkey": passkey
            })
            if(userResult){
                const token = generateJWTToken(userResult.centerId, userResult.auth.passkey);
                return res.status(201).json({
                    success: true,
                    message: "Login Successful",
                    token: token
                });
            }else{
                return res.status(401).json({
                    success: false,
                    message: "Invalid Credentials"
                });
            }
        }
    } catch (e) {
        console.error("Error in logIn", e);
        return res.status(500).json({
            success: false,
            message: "Internal Server Error"
        });
    }
}


export const signUp = async (req: Request, res: Response) => {
    try {
        const { email, isServiceProvider } = req.body;

        if (isServiceProvider) {
            const serviceProviderColl = await getCollection<ICenterAccount>("ServiceProvider", null);
            const serviceProviderResult = await serviceProviderColl.findOne({
                "auth.email": email
            });
            
            if (serviceProviderResult) {
                return res.status(409).json({
                    success: false,
                    message: "Email already exists"
                });
            }
            
            const passkey = "tms" + generatePasskey(null);
            const serviceProvider: ICenterAccount = {
                centerId: generatePasskey("TMS"),
                centerName: "",
                phoneNumber: "",
                centerUserName: "",
                auth: {
                    email: email,
                    passkey: passkey,
                    expiresAt: new Date(new Date().setFullYear(2025)).toISOString()
                },
                address: "",
                centerFeedback: "",
                centerRating: 0,
            };
            
            await serviceProviderColl.insertOne(serviceProvider);
            console.log("Service provider inserted");

            // Send welcome email with passkey
            await sendWelcomeEmail(email, "Tiffin Center Created Successfully", passkey, serviceProvider.centerId);

            return res.status(201).json({
                success: true,
                message: "Tiffin center created successfully"
            });
        } else {
            const userColl = await getCollection<IAccount>("User", null);
            const userResult = await userColl.findOne({
                "auth.email": email
            });

            if (userResult) {
                return res.status(409).json({
                    success: false,
                    message: "Email already exists"
                });
            }

            const passkey = generatePasskey(null);
            const user: IAccount = {
                centerId: "",
                Name: "",
                phoneNumber: "",
                userName: "",
                auth: {
                    email: email,
                    passkey: passkey,
                    expiresAt: new Date(new Date().setFullYear(2025)).toISOString()
                },
                address: "",
                previouslyRegisteredCenters: []
            };

            await userColl.insertOne(user);
            console.log("User inserted");

            // Send welcome email with passkey
            await sendWelcomeEmail(email, "User Account Created Successfully", passkey);

            return res.status(201).json({
                success: true,
                message: "User created successfully"
            });
        }
    } catch (error: any) {
        console.error("Error in signUp", error);
        return res.status(500).json({
            success: false,
            message: "Internal Server Error"
        });
    }
};

export const getAllUsers = async(req: Request, res: Response) => {
    try{
        const userColl = await getCollection<IAccount>("User", null);
        const users = await userColl.find().toArray();
        return res.status(200).json({
            success: true,
            users: users
        });
    
    }catch(error:any ){
        console.error("Error in getAllUsers", error);
        return res.status(500).json({
            success: false,
            message: "Internal Server Error"
        });
    }
}