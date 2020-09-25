//Naufal Ikhsan
//Blockchain Engineer Test

pragma solidity ^0.6.3;

import "SafeMath.sol";
import "Token.sol";

contract DepositWithdraw is ERC20{
    using SafeMath for uint256;
    address owner; //Alamat owner kontrak
    uint256 counterCall; //Penghitung Call
    
    uint256 totalDeposit; //Keseluruhan deposit
    
    mapping (address => uint256) private depositBalances; //Deposit setiap Address
    mapping (address => bool) public isUser; //Status user terdaftar
    
    modifier userNotExist(address _UserAddress) { //hanya untuk user tidak terdaftar
        require(!isUser[_UserAddress], "User Already Exist");
        _;
    }
    
    modifier userExist (address _UserAddress){ //hanya untuk user terdaftar
        require(isUser[_UserAddress], "User Not Exist");
        _;
    }
    
    //Mencatat event yang terjadi pada kontrak
    event ContractCreated(string _ContractName,address _OwnerAddress, uint256 _TimeCreated);
    event CreateUser(address _UserAddress, uint256 _TimeCreated);
    event LogDeposit(address _DepositAddress, uint256 _AmountDeposit, uint256 _TimeDeposit);
    event LogWithdraw(address _WithdrawAddress, uint256 _AmountWithDraw, uint256 _TimeWithdraw);
    

    constructor() public{
        owner=msg.sender;
        emit ContractCreated("DepositWithdraw Contract", owner, now);
    }
    
    //Fungsi untuk mendaftarkan address dan mendapat reward token
    function registerUser(address _NewUserAddress) public userNotExist(_NewUserAddress) {
        require(_NewUserAddress!=address(0),"Not an ETH address"); //Mengecek alamat yang didaftarkan adalah ETH address
        
        isUser[_NewUserAddress]=true; //Mendaftarkan address
        _mint(_NewUserAddress,100); //Mencetak token reward sebanyak 100
        
        emit CreateUser(_NewUserAddress, now);
        
        counterCall=counterCall+1; //Penambahan untuk counter Call
    }
    
    //Funngsi untuk melakukan deposit token
    function deposit(uint256 _depositAmount) public userExist(msg.sender){
        require(_depositAmount >= 10, "Minimum Deposit is 10 Token"); //Mengecek minimum deposit adalah 10 Token
        
        depositBalances[msg.sender]=depositBalances[msg.sender].add(_depositAmount); //Mencatat saldo deposit pengguna
        totalDeposit=totalDeposit.add(_depositAmount); //Mencatat keseluruhan saldo deposit kontrak
        
        transfer(owner, _depositAmount); //Pengiriman token menuju alamat penampungan token
        
        emit LogDeposit(msg.sender, _depositAmount, now);
        
        counterCall=counterCall+1; //Penambahan untuk counter Call
    }
    
    
    //Fungsi untuk melakukan withdraw token
    function withdraw(uint256 _withdrawAmount) public userExist(msg.sender){
        require(counterCall >= 10, "Contract must call 10 time"); //Mengecek minimum Call adalah 10 kali
        require(depositBalances[msg.sender] >= _withdrawAmount,"Withdrawal exceeds your deposit"); //Mengecek saldo deposit cukup untuk melakukan penarikan
        
        depositBalances[msg.sender]=depositBalances[msg.sender].sub(_withdrawAmount); //Mengurangi saldo deposit untuk ditarik
        totalDeposit=totalDeposit.sub(_withdrawAmount); //Mengurangi keseluruhan saldo deposit kontrak
        
        _transfer(owner, msg.sender, _withdrawAmount); //Penarikan token dari alamat penampungan token
        
        emit LogWithdraw(msg.sender, _withdrawAmount, now);
        
        counterCall=counterCall+1; //Penambahan untuk counter Call
    }
    
    
    //Fungsi untuk melihat saldo deposit
    function checkDepositedBalances(address _UserAddress) public view  returns (uint256) {
        return depositBalances[_UserAddress];
    }
    
    //Fungsi untuk melihat token yang tersedia
    function checkTokenBalances(address _UserAddress) public view returns (uint256){
        return balanceOf(_UserAddress);
    }
    
    //Fungsi untuk melihat keseluruhan token yang terdeposit
    function checkAllTotalDeposited() public view returns (uint256) {
        return totalDeposit;
    }
    
    //Fungsi untuk melihat jumlahh Call kontrak
    function checkCounterCall()public view returns (uint256) {
        return counterCall;
    }
    
    //Fungsi untuk melihat status User
    function checkUser(address _UserAddress) public view returns(string memory){
        if((isUser[_UserAddress]) && (_UserAddress != owner)){
            return "Registered User";
        }
        else{
            return "Not Registered";
        }
    }
}