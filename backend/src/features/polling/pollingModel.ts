export interface IPoll{
    pollId:string;
    centerId:string | undefined;
    centerName:string;
    items: IPollItem[];
    userNameResponse: string[];
}

export interface IPollItem{
    itemId:string;
    itemName:string;
    itemRating:number;
}