// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
 * @title SafeMath 
 * @dev Unsigned math operations with safety checks that revert on error.
 */
library SafeMath {
    /**
     * @dev Multiplie two unsigned integers, revert on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, revert on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtract two unsigned integers, revert on underflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Add two unsigned integers, revert on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }
}


/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}

/**
 * @title ERC20 interface
 * @dev See https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool); 

    function approve(address spender, uint256 value) external returns (bool); 

    function transferFrom(address from, address to, uint256 value) external returns (bool); 

    function totalSupply() external view returns (uint256); 

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256); 

    event Transfer(address indexed from, address indexed to, uint256 value); 

    event Approval(address indexed owner, address indexed spender, uint256 value); 
}


/**
 * @title Standard ERC20 token
 * @dev Implementation of the basic standard token.
 */
contract StandardToken is IERC20, Context {
    using SafeMath for uint256; 
    
    mapping (address => uint256) internal _balances; 
    mapping (address => mapping (address => uint256)) internal _allowed; 
    
    uint256 internal _totalSupply; 
    
    /**
     * @dev Total number of tokens in existence.
     */
    function totalSupply() public override view returns (uint256) {
        return _totalSupply; 
    }

    /**
     * @dev Get the balance of the specified address.
     * @param owner The address to query the balance of.
     * @return A uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) public override view  returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner The address which owns the funds.
     * @param spender The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
     * @dev Transfer tokens to a specified address.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value) public virtual override returns (bool) {
        _transfer(_msgSender(), to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public override returns (bool) {
        _approve(_msgSender(), spender, value); 
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     */
    function transferFrom(address from, address to, uint256 value) public virtual override returns (bool) {
        _transfer(from, to, value); 
        _approve(from, _msgSender(), _allowed[from][_msgSender()].sub(value)); 
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when _allowed[msg.sender][spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowed[_msgSender()][spender].add(addedValue)); 
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when _allowed[msg.sender][spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowed[_msgSender()][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Transfer tokens for a specified address.
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "Cannot transfer to the zero address"); 
        _balances[from] = _balances[from].sub(value); 
        _balances[to] = _balances[to].add(value); 
        emit Transfer(from, to, value); 
    }

    /**
     * @dev Approve an address to spend another addresses' tokens.
     * @param owner The address that owns the tokens.
     * @param spender The address that will spend the tokens.
     * @param value The number of tokens that can be spent.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0), "Cannot approve to the zero address"); 
        require(owner != address(0), "Setter cannot be the zero address"); 
	    _allowed[owner][spender] = value;
        emit Approval(owner, spender, value); 
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a `Transfer` event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal virtual {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowed[account][_msgSender()].sub(amount));
    }

}


contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


/**
 * @dev Extension of `ERC20` that adds a set of accounts with the `MinterRole`,
 * which have permission to mint (create) new tokens as they see fit.
 *
 * At construction, the deployer of the contract is the only minter.
 */
contract ERC20Mintable is StandardToken, MinterRole {
    uint256 public constant cap = 2000000000 * (10**18); //20???
    /**
     * @dev See `ERC20._mint`.
     *
     * Requirements:
     *
     * - the caller must have the `MinterRole`.
     */
    function mint(address account, uint256 amount) public onlyMinter returns (bool) {
        require(totalSupply().add(amount)<= cap, "more than token limit");
        _mint(account, amount);
        return true;
    }
}


contract AppleToken is ERC20Mintable, Ownable{

//---------------Token Info---------------//    
    string public constant name = "Apple";
    string public constant symbol = "Apple";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 200000000 * 10 ** 18;
    
    address public swapGovContract;
    // bool setGovFlag = false;

//---------------Lock Info---------------//
    uint256 public techReleaseByDay = 6040 * 10 ** 18; 
    uint256 public capitalReleaseByDay =64 * 10 ** 18;
    uint256 public nodeReleaseByDay = 44 * 10 ** 18;
    uint256 public lockreleasetime = 1620576000; //05.10
    // uint256 public lockedAmount;
    

    struct LockInfo {
        uint256 initLock;
        uint256 lockedAmount;
        uint256 lastUnlockTs;
        uint256 releaseType;
    }

    mapping(address => LockInfo) public lockedUser;

    event Lock(address account, uint256 startTime, uint256 amount, uint256 releaseType);
    event UnLock(address account, uint256 unlockTime, uint256 amount);
//---------------Blacklist module---------------// 
    mapping(address => bool) private _isBlackListed;
    event AddedBlackLists(address[]);
    event RemovedBlackLists(address[]);

    constructor() public {
        _totalSupply = INITIAL_SUPPLY;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);


    }

    function isBlackListed(address user) public view returns (bool) {
        return _isBlackListed[user];
    }

    function addBlackLists(address[] calldata _evilUser) public onlyOwner {
        for (uint i = 0; i < _evilUser.length; i++) {
            _isBlackListed[_evilUser[i]] = true;
        }
        emit AddedBlackLists(_evilUser);
    }

    function removeBlackLists(address[] calldata _clearedUser) public onlyOwner {
        for (uint i = 0; i < _clearedUser.length; i++) {
            delete _isBlackListed[_clearedUser[i]];
        }
        emit RemovedBlackLists(_clearedUser);
    }
    
    
    // function lockToGov() public onlyOwner {
    //     _transfer(_owner, swapGovContract, MINEREWARD); // transfer/freeze to swapGovContract
    //     lockedAmount = lockedAmount.add(MINEREWARD);
    // }
    function lock(address _account, uint256 _amount, uint256 _type) public onlyOwner {
        require(_type > 0 && _type < 4);
        require(_account != address(0), "Cannot transfer to the zero address");
        require(lockedUser[_account].lockedAmount == 0, "exist locked token");
        require(_account != swapGovContract, "equal to swapGovContract");
        lockedUser[_account].initLock = _amount;
        lockedUser[_account].lockedAmount = _amount;
        lockedUser[_account].lastUnlockTs = block.timestamp >= lockreleasetime ? block.timestamp : lockreleasetime;
        lockedUser[_account].releaseType = _type;
        _balances[_msgSender()] = _balances[_msgSender()].sub(_amount);
        _balances[_account] = _balances[_account].add(_amount);
        emit Lock(_account, block.timestamp, _amount, _type);
        emit Transfer(_msgSender(), _account, _amount);
    }

    function unlock() public {
        uint256 amount = getAvailablelockAmount(_msgSender(), lockedUser[_msgSender()].releaseType);
        require(amount > 0, "amount equal 0");
        lockedUser[_msgSender()].lockedAmount = lockedUser[_msgSender()].lockedAmount.sub(amount);
        lockedUser[_msgSender()].lastUnlockTs = block.timestamp;
        emit UnLock(_msgSender(), block.timestamp, amount);
    }

    function getAvailablelockAmount(address account, uint256 releaseType) public view returns (uint256) {
        if(lockedUser[account].lockedAmount == 0) {
            return 0;
        }

        if(block.timestamp <= lockedUser[account].lastUnlockTs) {
            return 0;
        }

        uint256 _days = block.timestamp.sub(lockedUser[account].lastUnlockTs).div(86400);
        if(_days > 0 && releaseType == 1) {
            uint256 _releaseAmount = _days.mul(techReleaseByDay);
            return lockedUser[account].lockedAmount > _releaseAmount ? _releaseAmount : lockedUser[account].lockedAmount;
        }

        if(_days > 0 && releaseType == 2) {
            uint256 _releaseAmount = _days.mul(capitalReleaseByDay);
            return lockedUser[account].lockedAmount > _releaseAmount ? _releaseAmount : lockedUser[account].lockedAmount;
        }

        if(_days > 0 && releaseType == 3) {
            uint256 _releaseAmount = _days.mul(nodeReleaseByDay);
            return lockedUser[account].lockedAmount > _releaseAmount ? _releaseAmount : lockedUser[account].lockedAmount;
        }
        return 0;
    }

    function transfer(address _to, uint256 _value) public override returns (bool) {
        require(!isBlackListed(_msgSender()));
        require(!isBlackListed(_to));
        require(_balances[_msgSender()].sub(lockedUser[_msgSender()].lockedAmount) >= _value);
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
        require(!isBlackListed(_msgSender()));
        require(!isBlackListed(_from));
        require(!isBlackListed(_to));
        require(_balances[_from].sub(lockedUser[_from].lockedAmount) >= _value);
        return super.transferFrom(_from, _to, _value);
    }

    /**
     * @dev Transfer tokens to multiple addresses.
     */
    function batchTransfer(address[] memory addressList, uint256[] memory amountList) public onlyOwner returns (bool) {
        uint256 length = addressList.length;
        require(addressList.length == amountList.length, "Inconsistent array length");
        require(length > 0 && length <= 150, "Invalid number of transfer objects");
        uint256 amount;
        for (uint256 i = 0; i < length; i++) {
            require(amountList[i] > 0, "The transfer amount cannot be 0");
            require(addressList[i] != address(0), "Cannot transfer to the zero address");
            require(!isBlackListed(addressList[i]));
            amount = amount.add(amountList[i]);
            _balances[addressList[i]] = _balances[addressList[i]].add(amountList[i]);
            emit Transfer(_msgSender(), addressList[i], amountList[i]);
        }
        require(_balances[_msgSender()].sub(lockedUser[_msgSender()].lockedAmount) >= amount, "Not enough tokens to transfer");
        _balances[_msgSender()] = _balances[_msgSender()].sub(amount);
        return true;
    }

    function burn(uint256 amount) public virtual {
        _checkBeforeBurn(_msgSender(), amount);
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        _checkBeforeBurn(account, amount);
        _burnFrom(account, amount);
    }

    function _checkBeforeBurn(address account, uint256 amount) internal {
        uint256 amt = lockedUser[account].lockedAmount;
        if (amt > 0) {
            require(balanceOf(account).sub(amt) >= amount, "token balance no enought burn");
            }
        
    }


    
    function setGovAddr(address _swapGovContract) public onlyOwner {
        // require(!setGovFlag); // only once
        swapGovContract = _swapGovContract;
        // setGovFlag = true;
    }
    function setReleaseByDay(uint256 _techReleaseByDay, uint256 _capitalReleaseByDay, uint256  _nodeReleaseByDay) public onlyOwner {
        require(_techReleaseByDay > 0, " must be great 0");
        require(_capitalReleaseByDay > 0, " must be great 0");
        require(_nodeReleaseByDay > 0, " must be great 0");
        techReleaseByDay = _techReleaseByDay;
        capitalReleaseByDay = _capitalReleaseByDay;
        nodeReleaseByDay = _nodeReleaseByDay;
    }
}