import { getCollection } from "../../db/db";
import { Request, Response } from "express";
import {IAccount, ICenterAccount} from "./accountModel";
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
                    token: token,
                    data: serviceProviderResult
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
                    token: token,
                    data: userResult
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
            const {centerName, phoneNumber, address} = req.body;
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
                centerName: centerName || "",
                phoneNumber: phoneNumber || "",
                centerUserName: centerName.replace(/\s+/g, '') + "@tms",
                auth: {
                    email: email,
                    passkey: passkey,
                    expiresAt: new Date(new Date().setFullYear(2025)).toISOString()
                },
                address: address  || "",
                centerFeedback: [],
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
                paymentMethod: {
                    card: {
                        cardNumber: "",
                        expiryDate: "",
                        cvv: "",
                        cardHolderName: "",
                        cardType: "",
                        cardIssuer: "",
                        cardNetwork: "",
                        cardCountry: "",
                        cardBank: "",
                        cardBrand: "",
                        cardStatus: "",
                        cardCurrency: "",
                        cardLimit: 0,
                        cardBalance: 0,
                        cardTransactions: []
                    },
                    bank: {
                        accountNumber: "",
                        ifsc:"",
                        accountHolderName: "",
                        bankName: "",
                        bankBranch: "",
                        bankCountry: "",
                        bankCurrency: "",
                        bankBalance: 0,
                        bankTransactions: []
                    },
                    upi:{
                        upiId: "",
                        upiHolderName: "",
                        upiBank: "",
                        upiCountry: "",
                        upiCurrency: "",
                        upiBalance: 0,
                        upiTransactions: []
                    },
                    wallet: {
                        walletId: "",
                        walletHolderName: "",
                        walletCountry: "",
                        walletCurrency: "",
                        walletBalance: 0,
                        walletTransactions: []
                    }
                    
                },
                previouslyRegisteredCenters: [],
                activeSubscriptions: [],
                previousSubscriptions: []
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

export const updateUserAccount = async(req: Request, res: Response) =>{
    try{
        const {email, passkey} = req.body;
        const userColl = await getCollection<IAccount>("User", null);
        const userResult = await userColl.findOne({
            "auth.email": email,
            "auth.passkey": passkey
        });
        if(userResult){
            const {Name, phoneNumber, userName, address} = req.body;
            const updatedUser: IAccount = {
                centerId: userResult.centerId || "",
                Name: Name || userResult.Name,
                phoneNumber: phoneNumber || userResult.phoneNumber,
                userName: userName || userResult.userName,
                auth: userResult.auth,
                address: address || userResult.address,
                paymentMethod: userResult.paymentMethod || {
                    card: {
                        cardNumber: "",
                        expiryDate: "",
                        cvv: "",
                        cardHolderName: "",
                        cardType: "",
                        cardIssuer: "",
                        cardNetwork: "",
                        cardCountry: "",
                        cardBank: "",
                        cardBrand: "",
                        cardStatus: "",
                        cardCurrency: "",
                        cardLimit: 0,
                        cardBalance: 0,
                        cardTransactions: []
                    },
                    bank: {
                        accountNumber: "",
                        ifsc:"",
                        accountHolderName: "",
                        bankName: "",
                        bankBranch: "",
                        bankCountry: "",
                        bankCurrency: "",
                        bankBalance: 0,
                        bankTransactions: []
                    },
                    upi:{
                        upiId: "",
                        upiHolderName: "",
                        upiBank: "",
                        upiCountry: "",
                        upiCurrency: "",
                        upiBalance: 0,
                        upiTransactions: []
                    },
                    wallet: {
                        walletId: "",
                        walletHolderName: "",
                        walletCountry: "",
                        walletCurrency: "",
                        walletBalance: 0,
                        walletTransactions: []
                    }
                },
                previouslyRegisteredCenters: userResult.previouslyRegisteredCenters || [],
                activeSubscriptions: userResult.activeSubscriptions || [],
                previousSubscriptions: userResult.previousSubscriptions || []
            };
            await userColl.updateOne({
                "auth.email": email,
                "auth.passkey": passkey
            }, {
                $set: updatedUser
            });
            return res.status(200).json({
                success: true,
                message: "User account updated successfully"
            });
        }else{
            return res.status(401).json({
                success: false,
                message: "Invalid Credentials"
            });
        }
    }catch(error:any){
        console.error("Error in updateUserAccount", error);
        return res.status(500).json({
            success: false,
            message: "Internal Server Error"
        });
    }
}

export const searchServiceProvider = async(req: Request, res: Response) => {
    try{
        const {centerName} = req.body;
        const serviceProviderColl = await getCollection<ICenterAccount>("ServiceProvider", null);
        const serviceProviderResult = await serviceProviderColl.find({
            "centerName": centerName
        }).toArray();
        return res.status(200).json({
            success: true,
            serviceProviders: serviceProviderResult
        });
    }catch(error:any){
        console.error("Error in searchServiceProvider", error);
        return res.status(500).json({
            success: false,
            message: "Internal Server Error"
        });
    }
}

export const updateServiceAccount = async(req: Request, res: Response) => {
    try{
        const {email, passkey} = req.body;
        const serviceProviderColl = await getCollection<ICenterAccount>("ServiceProvider", null);
        const {
            centerName,
            phoneNumber,
            centerUserName,
            address,
            centerFeedback,
            centerRating
        } = req.body;
        const serviceProviderResult = await serviceProviderColl.findOne({
            "auth.email": email,
            "auth.passkey": passkey
        });
        if(serviceProviderResult !== null){
            const updatedServiceProvider: ICenterAccount = {
                centerId: serviceProviderResult.centerId,
                centerName: centerName || serviceProviderResult.centerName,
                phoneNumber: phoneNumber || serviceProviderResult.phoneNumber,
                centerUserName: centerUserName || serviceProviderResult.centerUserName,
                auth: serviceProviderResult.auth,
                address: address || serviceProviderResult.address,
                centerFeedback: centerFeedback || serviceProviderResult.centerFeedback,
                centerRating: centerRating || serviceProviderResult.centerRating
            };
            await serviceProviderColl.updateOne({
                "auth.email": email,
                "auth.passkey": passkey
            }, {
                $set: updatedServiceProvider
            });
            return res.status(200).json({
                success: true,
                message: "Service provider account updated successfully"
            });
        }else{
            return res.status(401).json({
                success: false,
                message: "Invalid Credentials"
            });
        }
    }catch(error:any){
        console.error("Error in updateServiceAccount", error);
        return res.status(500).json({
            success: false,
            message: "Internal Server Error"
        })
    }
}