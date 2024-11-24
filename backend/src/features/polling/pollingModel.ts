export interface IPoll{
    pollId:string;
    pollName:string;
    centerId:string | undefined;
    centerName:string;
    items: IPollItem[];
    userNameResponse: string[];
}

export interface IPollItem{
    itemId:string;
    itemName:string;
    itemVote:number;
}


/*
{
"pollId": "673f0b90d077c47c905e6189",
"centerId": "tms_12BC34",
"centerName": "Nakoda Tiffin Center",
"items": [
    {
    "itemId": "item_1",
    "itemName": "Aloo Sabzi",
    "itemRating": 4.5
    },
    {
    "itemId": "item_2",
    "itemName": "Bhindi Sabzi",
    "itemRating": 4
    },
    {
    "itemId": "item_3",
    "itemName": "Gilki ki Sabzi",
    "itemRating": 3.8
    }
],
"userNameResponse": []
}
*/