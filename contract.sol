pragma solidity ^0.5.11;

import "./EIP20Interface.sol";

contract AtomicSwap {
    struct Order {
        address From;
        address IsERC20;
        uint256 EndTime;
        uint256 Amount;
        bytes32 Hash;
    }
    Order[] public Orders;
    uint256 public Fee;
    address public Owner;
    
    event NewOrder(uint256 indexed order_idx, uint256 opposite_idx, address is_ERC20, uint256 amount_from, uint256 amount_to, bytes32 hash, uint256 end_time);
    event Withdrawn(uint256 indexed order_idx, bytes key, uint256 end_time);
    
    constructor() public {
        Fee = 10;
        Owner=msg.sender;
        Orders.push(Order(address(0x0), address(0x0), 0, 0, ""));
    }
    
    function new_order(uint256 opposite_idx, uint256 amount_from, uint256 amount_to, address isERC20, uint256 end_time, bytes32 hash) public payable {
        uint256 idx = Orders.push(
            Order(
                msg.sender,
                isERC20,
                end_time,
                amount_from,
                hash
            )
        )-1;
        
        if(isERC20==address(0x0)) {
            require(msg.value==amount_from);
        } else {
            require(EIP20Interface(isERC20).transferFrom(msg.sender, address(this), amount_from));
        }
        
        emit NewOrder(
            idx,
            opposite_idx,
            isERC20,
            amount_from,
            amount_to,
            hash,
            end_time
        );
    }
    
    function withdraw(uint256 order_idx, address to, bytes memory key) public {
        require(order_idx<Orders.length);
        Order storage current_order = Orders[order_idx];
        require(current_order.Hash != "" && current_order.Hash == sha256(key));
        
        current_order.Hash = "";
        if(current_order.EndTime>now) {
            if(current_order.IsERC20==address(0x0)) {
                address(uint160(to)).transfer(current_order.Amount*(1000-Fee)/1000);
                address(uint160(Owner)).transfer(current_order.Amount*Fee/1000);
            } else {
                require(EIP20Interface(current_order.IsERC20).transfer(to, current_order.Amount*(1000-Fee)/1000));
                require(EIP20Interface(current_order.IsERC20).transfer(Owner, current_order.Amount*Fee/1000));
            }
        } else {
            if(current_order.IsERC20==address(0x0)) {
                address(uint160(current_order.From)).transfer(current_order.Amount*Fee/1000);
                address(uint160(Owner)).transfer(current_order.Amount*Fee/1000);
            } else {
                require(EIP20Interface(current_order.IsERC20).transfer(current_order.From, current_order.Amount*(1000-Fee)/1000));
                require(EIP20Interface(current_order.IsERC20).transfer(Owner, current_order.Amount*Fee/1000));
            }
        }
        emit Withdrawn(order_idx, key, now);
    }
    
    function set_fee(uint8 fee) public {
        require(msg.sender==Owner);
        require(fee>0 && fee<1000);
        Fee=fee;
    }
}
