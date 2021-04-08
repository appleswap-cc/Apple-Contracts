
pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;
/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
contract Context {
    function _msgSender() internal view  returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view  returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following 
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);
    function mint(address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount) external returns (bool);
    function decimals() external view returns (uint256);
    
    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public  onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public  onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IAppleSwapFactory {
    event PairCreated(address indexed pair, address stock, address money, bool isOnlySwap);

    function createPair(address stock, address money, bool isOnlySwap) external returns (address pair);
    function setFeeToAddresses(address) external;
    function setFeeToSetter(address) external;
    function setFeeBPS(uint32 bps) external;
    function setPairLogic(address implLogic) external;

    function allPairsLength() external view returns (uint);
    function feeTo_1() external view returns (address);
    function feeTo_2() external view returns (address);
    function feeToPrivate() external view returns (address);
    function feeToSetter() external view returns (address);
    function feeBPS() external view returns (uint32);
    function pairLogic() external returns (address);
    function getTokensFromPair(address pair) external view returns (address stock, address money);
    function tokensToPair(address stock, address money, bool isOnlySwap) external view returns (address pair);
}

interface IAppleSwapPool {
    // more liquidity was minted
    event Mint(address indexed sender, uint stockAndMoneyAmount, address indexed to);
    // liquidity was burned
    event Burn(address indexed sender, uint stockAndMoneyAmount, address indexed to);
    // amounts of reserved stock and money in this pair changed
    event Sync(uint reserveStockAndMoney);

    function internalStatus() external view returns(uint[3] memory res);
    function getReserves() external view returns (uint112 reserveStock, uint112 reserveMoney, uint32 firstSellID);
    function getBooked() external view returns (uint112 bookedStock, uint112 bookedMoney, uint32 firstBuyID);
    function stock() external returns (address);
    function money() external returns (address);
    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint stockAmount, uint moneyAmount);
    function skim(address to) external;
    function sync() external;
}

contract AppleExchange is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    IAppleSwapFactory factory;
    IAppleSwapPool AppleSwapPool;
    address public ApplePair;
    mapping (address => bool) Pairstatus;
    mapping (address => uint256) PairPid;

    struct UserInfo {
        uint256 transactionValue; //交易市值
        uint256 feeamount;  //以usdt计算
        uint256 AppleReward;
        uint256 AppleRewarded;
        uint256 lasttime;
    }

    struct PairInfo {
        address pair;
        address token0;
        address token1;
        address marktoken;
        uint256 exchangerate;
        uint256 AppleTotal;
        uint256 totalAmount;
        uint256 transactionValue; //pair总交易市值
    }

    IERC20 public Appletoken;
    PairInfo[] public Pairinfo;

    mapping (uint256 => mapping (address => UserInfo)) public users;
    address public Router;
    event Deposit(address indexed user, uint256 _pid, uint256 amount);
    event WithdrawApple(address user, uint256 _pid, uint256 amount);
    event exchange(address user, address pair, uint256 value, uint256 appleAmount);
    event Add(uint256 _pid, address _pair, address _token0, address _token1, address _marktoken);
    constructor(IERC20 _Appletoken, IAppleSwapFactory _factory, address _ApplePair, address _Router) public { 
        Appletoken = _Appletoken;
        factory = _factory;
        ApplePair = _ApplePair;
        Router = _Router;
    }
    function setAddress(IAppleSwapFactory _factory, address _ApplePair, address _Router) onlyOwner public{
        factory = _factory;
        ApplePair = _ApplePair;
        Router = _Router;
    }
    function setexchangerate(uint256 _pid, uint256 _exchangerate) onlyOwner public{
        PairInfo storage pair = Pairinfo[_pid];
        pair.exchangerate = _exchangerate;
    }
    modifier validatePair(uint256 _pid) {
        require(_pid < Pairinfo.length, " Pair exists?");
        _;
    }
    modifier onlyRouter{
        require(msg.sender == Router, " olny route can call");
        _;
    }

    function getPair() view public returns(PairInfo[] memory){
        return Pairinfo;
    }

    //添加pair
    function addPair(address _pair, address _token0, address _token1, address _marktoken, uint256 _exchangerate) public onlyOwner {
        require(!Pairstatus[_pair], "pair already add");
        Pairinfo.push(PairInfo({
            pair: _pair,
            token0: _token0,
            token1: _token1,
            marktoken: _marktoken,
            exchangerate: _exchangerate,
            AppleTotal:0,
            totalAmount: 0,
            transactionValue: 0
        }));
        Pairstatus[_pair] = true;
        uint256 length = Pairinfo.length;
        PairPid[_pair] = length.sub(1);
        emit Add(length.sub(1), _pair, _token0, _token1, _marktoken);
    }
  
    
    function pendingApple(uint256 _pid, address _user) public view validatePair(_pid) returns (uint256)  {
        UserInfo storage user = users[_pid][_user];
        return user.AppleReward;
    }

    function totalreward(uint256 _pid, address _user) public view validatePair(_pid) returns(uint256) {
        UserInfo storage user = users[_pid][_user];
        return user.AppleReward.add(user.AppleRewarded);
    }
    function getpairlegth() view public returns(uint256) {
        return Pairinfo.length;

    }
    function getAppleAmount(address stableAddress, uint256 amount) view public returns(uint256){
        if (amount >0 ){
            (address stock, address money) =IAppleSwapFactory(factory).getTokensFromPair(ApplePair);
            (uint256 AppleAmount, uint256 stableAmount, ) = IAppleSwapPool(ApplePair).getReserves();
            //Apple扩大1e6倍的价格，等于稳定币的数量/Apple的数量（两种代币都不带精度）
            uint256  ApplePrice = stableAmount.mul(1e6).div(10 ** IERC20(money).decimals()).div(AppleAmount.div(10 ** IERC20(stock).decimals()));
            //本次交易费能换多少个Apple（带精度）等于扩大1e6倍的稳定币数量（带精度）*Apple的精度/稳定币精度/Apple的价格。化简后（（usdt数量/Apple价格）*Apple精度）
            uint256 ExAppleAmount = amount.mul(10 ** IERC20(stock).decimals()).div(10 ** IERC20(stableAddress).decimals()).div(ApplePrice);
            return ExAppleAmount;
        }else{
            return 0;
        }
    }
    //抵押
    function Exchange(address _user, address _path, address _input, uint256 _amountIn, uint256 _amountOut) public onlyRouter returns(bool){
        require(_user != address(0), "user equal to 0");
        require(_path != address(0)," _path equal to 0");
        if (getpairlegth() <= 0){
            return false;
        }
        //交易对被添加 
        if (!Pairstatus[_path]) {
            return false;
        }
        //交易对的pid
        uint256 _pid = PairPid[_path];
        PairInfo storage pair = Pairinfo[_pid];
        UserInfo storage user = users[_pid][_user];
        //获取交易对两种代币地址
        (address stock, address money) =IAppleSwapFactory(factory).getTokensFromPair(_path);
        //判断两种代币地址与添加pair地址相同
        if (pair.token0 != stock || pair.token1 != money) {
            return false;
        }
        if (_input == pair.marktoken) {
            uint256 amount = _amountIn.mul(1e6).mul(3).div(1000); //计算手续费是多少个稳定币，防止精度问题扩大10**6
            user.feeamount = user.feeamount.add(amount); //记录用户总的手续费数量
            uint256 AppleAmount = getAppleAmount(_input, amount).mul(pair.exchangerate).div(10); //获取本次手续费可兑换的平台币数量
            user.AppleReward = user.AppleReward.add(AppleAmount); //记录用户可领取的平台币数量
            user.transactionValue = user.transactionValue.add(_amountIn);
            user.lasttime = block.timestamp;
            //更新池子总的手续费和总兑换的平台币数量
            pair.transactionValue = pair.transactionValue.add(_amountIn);
            pair.totalAmount = pair.totalAmount.add(amount);
            pair.AppleTotal = pair.AppleTotal.add(AppleAmount);
            emit exchange(_user, _path, _amountIn, AppleAmount);
        }else{
            _input = (stock != _input) ? stock : money;
            uint256 amount = _amountOut.mul(1e6).mul(3).div(997);//计算公式为x - 千分之3x = _amountOut  化简出千分之3x    跨多个路径只能计算到属于这个交易对的手续费
            user.feeamount = user.feeamount.add(amount);
            uint256 AppleAmount = getAppleAmount(_input, amount).mul(pair.exchangerate).div(10);
            user.transactionValue = user.transactionValue.add(_amountOut.mul(1000).div(997));
            user.AppleReward = user.AppleReward.add(AppleAmount);
            user.lasttime = block.timestamp;
            pair.transactionValue = pair.transactionValue.add(_amountOut.mul(1000).div(997));
            pair.totalAmount = pair.totalAmount.add(amount);
            pair.AppleTotal = pair.AppleTotal.add(AppleAmount);
            emit exchange(_user, _path, _amountOut.mul(1000).div(997), AppleAmount);
        }

        return true;
    }


    //提取Apple
    function withdraw(uint256 _pid) public validatePair(_pid){
        UserInfo storage user = users[_pid][msg.sender];
        uint256 appleReward = user.AppleReward;
        if (appleReward > 0 ){
            safeAppleTransfer(msg.sender,  appleReward);
        }
        user.AppleReward = 0;
        user.AppleRewarded = user.AppleRewarded.add(appleReward);
        emit WithdrawApple(msg.sender, _pid, appleReward);
    }

    function safeAppleTransfer(address _to, uint256 _amount) internal {
        uint256 AppleBalance = Appletoken.balanceOf(address(this));
        require(AppleBalance >= _amount, "no enough token");
        Appletoken.transfer(_to, _amount);
    }

}