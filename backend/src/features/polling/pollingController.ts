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
            itemVote: 0
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

export const createPoll = async (req: Request, res: Response) => {
    try {
        const { centerId } = req.query;
        const {
            centerName,
            pollName,
            items
        } = req.body;

        // Validate input
        if (!centerId) {
            return res.status(400).json({
                message: "Center ID is required",
                success: false
            });
        }

        // Find center account to validate center exists
        const centerCollection = await getCollection<ICenterAccount>('ServiceProvider', centerId.toString());

        const centerAccount = await centerCollection.findOne({
            centerId: centerId.toString()
        });

        // Check if poll already exists for this center
        const pollCollection = await getCollection<IPoll>('polls', centerId.toString());
        const existingPoll = await pollCollection.findOne({
            centerId: centerId.toString()
        });

        if (existingPoll) {
            return res.status(400).json({
                message: "Poll already exists for this center",
                success: false
            });
        }

        // Prepare poll object
        const poll: IPoll = {
            pollId: new ObjectId().toHexString(),
            centerId: centerId.toString(),
            pollName: pollName,
            centerName: centerName || "",
            items: (items || []).map((item: { itemId?: string; itemName: string; itemRating?: number }) => ({
                itemId: item.itemId || new ObjectId().toHexString(),
                itemName: item.itemName,
                itemRating: item.itemRating || 0
            })),
            userNameResponse: []
        };

        // Insert poll
        const result = await pollCollection.insertOne(poll);

        if (!result) {
            return res.status(500).json({
                message: "Failed to create poll",
                success: false
            });
        }

        return res.status(201).json({
            message: "Poll created successfully",
            success: true,
            data: {
                pollId: poll.pollId
            }
        });

    } catch (error: any) {
        console.error("Error in createPoll:", error);
        return res.status(500).json({
            message: "Internal server error",
            success: false,
            error: error.message
        });
    }
};

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
            data:poll,
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

export const deletePoll = async(req:Request,res:Response) => {
    try{
        const {centerId, pollId} = req.query;
        console.log(centerId,pollId);
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
        const deletedPoll = await pollColl.deleteOne({
            pollId: pollId?.toString()
        });
        if(!deletedPoll){
            console.log("failed to delete poll");
            return res.status(500).json({
                message: "Failed to delete poll",
                success: false
            })
        }
        console.log("confirm delete");
        return res.status(200).json({
            message: "Poll deleted successfully",
            success: true
        })
        
    }catch(error:any){
        console.error("An error occurred while deleting poll",error);
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