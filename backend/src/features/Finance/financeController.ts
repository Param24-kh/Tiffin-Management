import { IFinance } from "./financeModel"
import { Request, Response } from "express"
import { getCollection } from "../../db/db"
import { ObjectId } from "mongodb"

export const createFinance = async (req: Request, res: Response) => {
    try{
        const {
            centerId,
            date,
            income,
            expense
        } = req.body;
        const financeColl = await getCollection<IFinance>("Finance", centerId?.toString());
        const finance: IFinance = {
            centerId: centerId,
            date: date,
            income: income,
            expense: expense
        }
        const result = await financeColl.insertOne(finance);
        return res.status(201).json({
            success: true,
            message: "Finance created successfully",
            data: result
        });
    }catch(error:any){
        console.error("Error in createFinance", error);
        return res.status(500).json({
            success: false,
            message: "Internal Server Error"
        });
    }
}

export const updateFinance = async (req: Request, res: Response) => {
    try{
        const {centerId, id } = req.query;
        const { date, income, expense } = req.body;
        const financeColl = await getCollection<IFinance>("Finance", centerId?.toString());
        const data = await financeColl.findOne({ _id: new ObjectId(id?.toString()) });
        const finance = {
            date: date,
            income: income,
            expense: expense
        }
        const result = await financeColl.findOneAndUpdate({
            _id: new ObjectId(id?.toString())
        }, {
            $set: { ...data, ...finance }
        }, { returnDocument: "after"
        })
        return res.status(200).json({
            success: true,
            message: "Finance updated successfully",
            data: result
        });

    }catch(error:any){
        console.error("Error in updateFinance", error);
        return res.status(500).json({
            success: false,
            message: "Internal Server Error"
        });
    }
}

export const getFinance = async (req: Request, res: Response) => {
    try{
        const { centerId } = req.query;
        const financeColl = await getCollection<IFinance>("Finance", centerId?.toString());
        const result = await financeColl.find().toArray();
        return res.status(200).json({
            success: true,
            message: "Finance fetched successfully",
            data: result
        });
    }catch(error:any){
        console.error("Error in getFinance", error);
        return res.status(500).json({
            success: false,
            message: "Internal Server Error"
        });
    }
}