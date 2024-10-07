import { getCollection, mongoErrorHander } from "../../db/db";
import { Router, Request, Response } from "express";
import {IAccount, IAuth} from "./accountModel";
import { generateJWTToken, generatePasskey } from "./ctrl_func";

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
    try {
        const { username, password } = req.body
        console.log(req.body);
        const centerColl = await getCollection<IAccount>("TiffinCenter", null);
        const result = await centerColl.findOne({
            "auth.password": password,
            $expr: {
                $gte: ['$auth.expiresAt', new Date().toISOString()]
            }
        })
        console.log(result);
        if (!result) {
            return res.status(404).json({ error: "Invalid Passkey" })
        }
        const key = result?.auth?.password === password ? result.auth : null;
        const user = {
            centerId: result.centerId,
            name: result.name,
            phoneNumber: result.phoneNumber,
            email: result.email,
            address: result.address,
            deliveryAddress:result.deliveryAddress,
            username:result.auth.username,
            sessionToken: generateJWTToken(result.centerId, key?.password ?? "")
        }
        return res.status(200).json({ user })
    } catch (e) {
        mongoErrorHander(e, "Error in Login Handled", "Error in Login")
        return res.status(500).json({ error: "Internal Server Error" })
    }
}