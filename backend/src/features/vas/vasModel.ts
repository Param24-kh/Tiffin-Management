export interface IVas{
    centerId:string;
    seviceId:string;
    service:Item[];
}
export interface Item{
    ItemId:string;
    ItemName:string;
    itemDescription:string;
    price:number;
}