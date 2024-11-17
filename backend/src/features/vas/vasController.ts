import {IVas, Item} from './vasModel'
import {Request, Response} from 'express'
import { getCollection} from '../../db/db'
import { ObjectId } from 'mongodb';
import { IAccount } from 'features/accounts/accountModel';


export const addService = async (req:Request,res:Response) => {
    try{
        const {centerId, service} = req.body;
        const vasColl = await getCollection<IVas>('vas', centerId?.toString());
        const vas:IVas = {
            centerId: centerId?.toString(),
            seviceId: new ObjectId().toHexString(),
            service: service.map((item:Item) => {
                return {
                    ItemId: new ObjectId().toHexString(),
                    ItemName: item.ItemName,
                    itemDescription: item.itemDescription,
                    price: item.price
                }
            })
        }
        const result = await vasColl.insertOne(vas);
        if(!result){
            return res.status(500).json({
                message: "Service not added",
                success: false
            })
        }
        return res.status(201).json({
            message: "Service added",
            success: true
        })
    }catch(error:any){
        console.error("An error occurred while adding service",error);
        return res.status(500).json({
            message: "Internal server error",
            success: false
        })
    }
}

export const getServices = async (req:Request,res:Response) => {
    try{
        const {centerId} = req.query;
        const vasColl = await getCollection<IVas>('vas', centerId?.toString());
        const result = await vasColl.find({
            centerId: centerId?.toString()
        }).toArray();
        if(!result){
            return res.status(404).json({
                message: "Service not found",
                success: false
            })
        }
        return res.status(200).json({
            message: "Service found",
            success: true,
            data: result
        })
    }catch(error:any){
        console.error("An error occurred while getting service",error);
        return res.status(500).json({
            message: "Internal server error",
            success: false
        })
    }
}

export const updateService = async (req:Request,res:Response) => {
    try{
        const {centerId, serviceId} = req.query;
        const mongoId = new ObjectId(serviceId as string);
        const {service} = req.body;
        const vasColl = await getCollection<IVas>('vas', centerId?.toString());
        const result = await vasColl.findOneAndUpdate(
            { _id: mongoId },
            { $set: { service: service } }
        );
        if(!result){
            return res.status(404).json({
                message: "Service not found",
                success: false
            })
        }
        return res.status(200).json({
            message: "Service updated",
            success: true
        })
    }catch(error:any){
        console.error("An error occurred while updating service",error);
        return res.status(500).json({
            message: "Internal server error",
            success: false
        })
    }
}

export const deleteService = async (req:Request,res:Response) => {
    try{
        const {centerId, serviceId} = req.query;
        const mongoId = new ObjectId(serviceId as string);
        const vasColl = await getCollection<IVas>('vas', centerId?.toString());
        const result = await vasColl.findOneAndDelete(
            { _id: mongoId }
        );
        if(!result){
            return res.status(404).json({
                message: "Service not found",
                success: false
            })
        }
        return res.status(200).json({
            message: "Service deleted",
            success: true
        })
    }catch(error:any){
        console.error("An error occurred while deleting service",error);
        return res.status(500).json({
            message: "Internal server error",
            success: false
        })
    }
}

export const purchaseService = async (req:Request,res:Response) => {
    try{
        const {centerId, serviceId, userName} = req.query;
        const mongoId = new ObjectId(serviceId as string);
        const vasColl = await getCollection<IVas>('vas', centerId?.toString());
        const userColl = await getCollection<IAccount>('User', centerId?.toString());
        const vas = await vasColl.findOne({
            _id: mongoId
        });
        if(!vas){
            return res.status(404).json({
                message: "Service not found",
                success: false
            })
        }
        const user = await userColl.findOneAndUpdate(
            { userName: userName?.toString() },
            { $push: {
                activeSubscriptions: vas._id.toString()
            }}
        );
        if(!user){
            return res.status(404).json({
                message: "User not found",
                success: false
            })
        }
    }catch(error:any){
        console.error("An error occurred while purchasing service",error);
        return res.status(500).json({
            message: "Internal server error",
            success: false
        })
    }
}