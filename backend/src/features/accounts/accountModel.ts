export interface IAccount {
    centerId:string;
    name:string;
    phoneNumber:string;
    email:string;
    address:string;
    deliveryAddress:string;
    auth: IAuth;
}

export interface IAuth{
    username:string;
    password:string;
    expiresAt:string;
}