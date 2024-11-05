export interface IAccount{
    centerId:string;
    Name:string;
    phoneNumber:string;
    userName:string;
    auth: IPasskey;
    address:string;
    previouslyRegisteredCenters: string[];
}

export interface ICenterAccount{
    centerId:string;
    centerName:string;
    phoneNumber:string;
    centerUserName:string;
    auth: IPasskey;
    address:string;
    centerFeedback:string;
    centerRating:number;
}

export interface IPasskey{
    email:string;
    passkey:string;
    expiresAt:string;
}