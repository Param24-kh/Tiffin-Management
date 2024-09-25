
export interface IPoll{
    centerId:string;
    ItemName:Item[];
}

export interface Item{
    ItemId:string;
    ItemName:string;
    count:number;
}