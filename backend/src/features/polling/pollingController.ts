import { getCollection } from "db/db";
import { IPoll } from "./pollingModel";
import { Request,Response } from "express";
import { ObjectId } from "mongodb";

export const addItem = async (req: Request, res: Response) => {

}


// export const incrementPoll = async (req: Request, res: Response) => {
//     try{
//         const { centerId, ItemName, accountId, pollId} = req.body;
//         const mongoId = new ObjectId(accountId as string);
//         const pollColl = await getCollection<IPoll>("Poll", centerId?.toString())
//         const poll = await pollColl.findOne({
//             _id: new ObjectId(pollId as string),
//         });
//         if(!poll?.accountId.find(id => id === mongoId.toString())){
//             await pollColl.findOneAndUpdate(
//                 {_id: new ObjectId(pollId as string)},
//                 {$inc: { "ItemName.$.count": 1 }, $push: { accountId: mongoId.toString() }}
//             );
//         }
//         if(!poll){
//             return res.status(404).json({
//                 success: false,
//                 message: "Poll not found"
//             });
//         }
//         return res.status(201).json({
//             success: true,
//             message: "Polled successfully",
//             data: poll
//         })
//     }catch(error:any){
//         console.error("Error in incrementPoll", error);
//         return res.status(500).json({
//             success: false,
//             message: error.message
//         });
//     }
// }