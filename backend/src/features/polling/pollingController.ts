import { uuid } from "uuidv4";
import { getCollection } from "../../db/db";
import { IPoll } from "./pollingModel";
import { Request,Response } from "express";
import { ObjectId } from "mongodb";
import { ICenterAccount } from "features/accounts/accountModel";

export const addItemToPoll = async (req:Request,res:Response) => {
    try{
        const {name} = req.body;
        const {pollId, centerId} = req.query;
        const pollColl = await getCollection<IPoll>('polls', centerId?.toString());
        const poll = await pollColl.findOne({
            pollId: pollId?.toString()
        });
        if(!poll){
            return res.status(404).json({
                message: "Poll not found",
                success: false
            })
        }
        const newItem = {
            itemId: new ObjectId().toHexString(),
            itemName: name,
            itemRating: 0
        }
        const updatedItems = await pollColl.updateOne({
            pollId: pollId?.toString()
        },{
            $push: {
                items: newItem
            }
        })
        return res.status(200).json({
            message: "Item added to poll",
            success: true
        })
    }catch(error:any){
        console.error("An error occurred while adding item to poll",error);
        return res.status(500).json({
            message: "Internal server error",
            success: false
        })
    }
}

export const createPoll = async (req:Request,res:Response) => {
    try{
    const{centerId} = req.query;
    const findName = await getCollection<ICenterAccount>('ServiceProvider',centerId?.toString());
    const find = await findName.findOne({
        centerId: centerId?.toString()
    });
    const name = find!.centerName;
    const pollColl = await getCollection<IPoll>('polls', centerId?.toString());
    const findPoll = await pollColl.findOne({
        centerId: centerId?.toString()
    });
    if(findPoll){
        return res.status(400).json({
            message: "Poll already exists",
            success: false
        })
    }
    const pollId = new ObjectId().toHexString();
    if(!pollColl){
        return res.status(404).json({
            message: "Center not found",
            success: false
        })
    }
    const poll:IPoll = {
        pollId: pollId,
        centerId: centerId?.toString(),
        centerName: name,
        items: [],
        userNameResponse: []
    }
    await pollColl.insertOne(poll);
    return res.status(201).json({
        message: "Poll created",
        success: true
    })
    }catch(error:any){
        console.error("An error occurred while creating poll",error);
        return res.status(500).json({
            message: "Internal server error",
            success: false
        })
    }
}

export const deleteItem = async (req:Request,res:Response) => {
    try{
        const {itemId, pollId, centerId} = req.query;
        const pollColl = await getCollection<IPoll>('polls', centerId?.toString());
        const poll = await pollColl.findOne({
            pollId: pollId?.toString()
        });
        if(!poll){
            return res.status(404).json({
                message: "Poll not found",
                success: false
            })
        }
        const updatedItems = await pollColl.updateOne({
            pollId: pollId?.toString()
        },{
            $pull: {
                items: {
                    itemId: itemId?.toString()
                }
            }
        })
        return res.status(200).json({
            message: "Item deleted from poll",
            success: true
        })
    }catch(error:any){
        console.error("An error occurred while deleting item",error);
        return res.status(500).json({
            message: "Internal server error",
            success: false
        })
    }
}

export const participateInPoll = async (req:Request,res:Response) => {
    try{
        const {pollId, itemId, centerId, userName} = req.query;
        const pollColl = await getCollection<IPoll>('polls', centerId?.toString());
        const poll = await pollColl.findOne({
            pollId: pollId?.toString()
        });
        if(!poll){
            return res.status(404).json({
                message: "Poll not found",
                success: false
            })
        }
        if(userName && poll.userNameResponse.includes(userName.toString())){
            return res.status(400).json({
                message: "User already participated in poll",
                success: false
            })
        }
        const item = poll?.items.find(item => item.itemId === itemId?.toString());
        if(!item){
            return res.status(404).json({
                message: "Item not found",
                success: false
            })
        }
        const updatedItems = await pollColl.updateOne({
            pollId: pollId?.toString(),
            "items.itemId": itemId?.toString()
        },{
            $inc: {
                "items.$.itemRating": 1
            },
            $push: {
                userNameResponse: userName?.toString()
            }
        })
        return res.status(200).json({
            message: "Voted successfully",
            success: true
        })
    }catch(error:any){
        console.error("An error occurred while participating in poll",error);
        return res.status(500).json({
            message: "Internal server error",
            success: false
        })
    }
}

export const decrementPoll = async (req:Request,res:Response) => {
    try{
        const{pollId, itemId, centerId, userName} = req.query;
        const pollColl = await getCollection<IPoll>('polls', centerId?.toString());
        const poll = await pollColl.findOne({
            pollId: pollId?.toString()
        });
        if(!poll){
            return res.status(404).json({
                message: "Poll not found",
                success: false
            })
        }
        if(!userName || !poll.userNameResponse.includes(userName.toString())){
            return res.status(400).json({
                message: "User did not participate in poll",
                success: true
            })
        }
        const item = poll?.items.find(item => item.itemId === itemId?.toString());
        if(!item){
            return res.status(404).json({
                message: "Item not found",
                success: false
            })
        }
        const updatedItems = await pollColl.updateOne({
            pollId: pollId?.toString(),
            "items.itemId": itemId?.toString()
        },{
            $inc: {
                "items.$.itemRating": -1
            },
            $pull: {
                userNameResponse: userName?.toString()
            }
        })
        return res.status(200).json({
            message: "Decremented poll",
            success: true
        })
    }catch(error:any){
        console.error("An error occurred while decrementing poll",error);
        return res.status(500).json({
            message: "Internal server error",
            success: false
        })
    }
}

export const viewPoll = async (req:Request,res:Response) => {
    try{
        const {centerId} = req.query;
        const pollColl = await getCollection<IPoll>('polls', centerId?.toString());
        const poll = await pollColl.find({
            centerId: centerId?.toString
        }).toArray();
        if(!poll){
            return res.status(404).json({
                message: "Poll not found",
                success: false
            })
        }
        return res.status(200).json({
            message: "Poll found",
            poll,
            success: true
        })
    }catch(error:any){
        console.error("An error occurred while viewing poll",error);
        return res.status(500).json({
            message: "Internal server error",
            success: false
        })
    }
}