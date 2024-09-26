
export interface IPoll{
    centerId:string;
    accountId:string[];
    ItemName:Item[];
    date:string;
}

export interface Item{
    ItemId:string;
    ItemName:string;
    count:number;
}