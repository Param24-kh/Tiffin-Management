import {Request, Response} from 'express'
import { Jwt } from 'jsonwebtoken'
import { getCollection } from '../../db/db'
import { IAccount } from './account';



export const signIn = async(req:Request, res:Response) => {
    try{const {
        username,
        password
    } = req.body;

    const userColl = await getCollection<IAccount>("Users", null);
    const users = await userColl.findOne({
        username:username?.toString(),
        password:password?.toString()
    })
    if(!users){
        console.error("User not exist ");
        return res.status(404).json({
            success:true,
            message:"404 User not found"
        })
    }
    return res.status(200).json({
        success:true,
        message:"SignIn Successfull",
        data:users
    })
    }catch(error:any){
        console.error("Internal Server Error ");
        return res.status(500).json({
            success:false,
            message:"Internal Server Error"
        })
    }
}