import { getCollection, mongoErrorHander } from "../../db/db";
import { Router, Request, Response } from "express";
import {IAccount, ICenterAccount,IPasskey} from "./accountModel";
import { generateJWTToken, generatePasskey } from "./ctrl_func";
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
/*
export const createPasskey = async (req: Request, res: Response) => {
    try {
        const { empId, role, hospitalId } = req.query; //mongoId
        const mongoEmpId = new ObjectId(empId as string);
        let date = new Date().setFullYear(2025);

        const passkey: IPasskey = {
            role: role?.toString(), //role of the employee
            empId: mongoEmpId.toString(),
            expiresAt: new Date(date).toISOString(),
            key: generatePasskey(null),
        };

        const hospitalColl = await getCollection<IHospital>("Hospitals", null);
        const result = await hospitalColl.findOneAndUpdate(
            { hospitalId: hospitalId?.toString() },
            { $push: { passkeys: passkey } },
            { returnDocument: "after" }
        );

        if (!result) {
            return res.status(404).json({
                success: false,
                message: "Hospital not found"
            });
        } else {
            return res.status(201).json({
                success: true,
                message: "Passkey created successfully"
            });
        }
    } catch (error: any) {
        console.error("Error in createPasskey", error);
        return res.status(500).json({
            success: false,
            message: error.message
        });
    }
};
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
    try{
        let {email, isServiceProvider} = req.body;

        if(isServiceProvider){
            const serviceProviderColl = await getCollection<ICenterAccount>("ServiceProvider", null);
            const serviceProviderResult = await serviceProviderColl.findOne({
                "auth.email": email
            })
            if(serviceProviderResult){
                return res.status(409).json({
                    success: false,
                    message: "Email already exists"
                });
            }
            const passkey = "tms"+generatePasskey(null);
            const serviceProvider: ICenterAccount = {
                centerId: generatePasskey("TMS"),
                centerName: "",
                phoneNumber:"",
                centerUserName:"",
                auth:{
                    email: email,
                    passkey:passkey,
                    expiresAt: new Date(new Date().setFullYear(2025)).toISOString()
                },
                address:"",
                centerFeedback:"",
                centerRating:0,
            }
            serviceProviderColl.insertOne(serviceProvider).then(() => { console.log("inserted") });
            return res.status(201).json({
                success: true,
                message: "Tiffin center created successfully",
                // to do setup nodemailer to send centerId and passkey to the user
            });
        }else {
            const centerColl = await getCollection<IAccount>("User", null);
            const userResult = await centerColl.findOne({
                "auth.email": email
            })
            if(userResult){
                return res.status(409).json({
                    success: false,
                    message: "Email already exists"
                });
            }
            const passkey = generatePasskey(null);
            const user: IAccount = {
                centerId: "",
                Name:"",
                phoneNumber:"",
                userName:"",
                auth:{
                    email: email,
                    passkey:passkey,
                    expiresAt: new Date(new Date().setFullYear(2025)).toISOString()
                },
                address:"",
                previouslyRegisteredCenters:[]
            }
            centerColl.insertOne(user).then(() => { console.log("inserted") });
            return res.status(201).json({
                success: true,
                message: "User created successfully"
                // to do setup nodemailer to send centerId and passkey to the user
            });
        }
    }catch(error:any){
        console.error("Error in signUp", error);
        return res.status(500).json({
            success: false,
            message: "Internal Server Error"
        });
    }
}