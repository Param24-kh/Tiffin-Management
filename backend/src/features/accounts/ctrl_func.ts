import { v4 as uuidv4 } from "uuid";
import jwt from 'jsonwebtoken'


export function generatePasskey(prefix: string | undefined | null): string {
    if (!prefix) {
        return uuidv4().substring(0, 6).toUpperCase(); // Take the first 6 characters and convert to uppercase
    } else {
        return "tms_" + uuidv4().substring(0, 6).toUpperCase(); // Take the first 6 characters and convert to uppercase
    }
}

export function generateJWTToken(centerId: string, passkey: string): string {
    if(centerId === "" || centerId === null){
        centerId = "tmp_" + uuidv4().substring(0, 6).toUpperCase();
    }
    const payLoad = { centerId, passkey }
    return jwt.sign(payLoad, "15m")
}