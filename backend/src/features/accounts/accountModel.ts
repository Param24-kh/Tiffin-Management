export interface IAccount{
    centerId:string;
    Name:string;
    phoneNumber:string;
    userName:string;
    auth: IPasskey;
    address:string;
    paymentMethod: IPaymentMethod;
    previouslyRegisteredCenters: string[];
    activeSubscriptions: string[];
    previousSubscriptions: string[];
}
export interface IPaymentMethod{
    card: card;
    bank: bank;
    upi: upi;
    wallet: wallet;
}

export interface bank{
    accountNumber:string;
    ifsc:string;
    accountHolderName:string;
    bankName:string;
    bankBranch:string;
    bankCountry:string;
    bankCurrency:string;
    bankBalance:number;
    bankTransactions: ITransaction[];
}

export interface wallet{
    walletId:string;
    walletHolderName:string;
    walletCountry:string;
    walletCurrency:string;
    walletBalance:number;
    walletTransactions: ITransaction[];
}

export interface upi{
    upiId:string;
    upiHolderName:string;
    upiBank:string;
    upiCountry:string;
    upiCurrency:string;
    upiBalance:number;
    upiTransactions: ITransaction[];
}

export interface ITransaction{
    transactionId:string;
    transactionDate:string;
    transactionAmount:number;
    transactionStatus:string;
    transactionType:string;
    transactionMode:string;
    transactionDescription:string;
    transactionCurrency:string;
    transactionBalance:number;
}

export interface ICardTransaction{
    transactionId:string;
    transactionDate:string;
    transactionAmount:number;
    transactionStatus:string;
    transactionType:string;
    transactionMode:string;
    transactionDescription:string;
    transactionCurrency:string;
    transactionBalance:number;
}
export interface card{
    cardNumber:string;
    expiryDate:string;
    cvv:string;
    cardHolderName:string;
    cardType:string;
    cardIssuer:string;
    cardNetwork:string;
    cardCountry:string;
    cardBank:string;
    cardBrand:string;
    cardStatus:string;
    cardCurrency:string;
    cardLimit:number;
    cardBalance:number;
    cardTransactions: ICardTransaction[];
}


export interface ICenterAccount{
    centerId:string;
    centerName:string | "";
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