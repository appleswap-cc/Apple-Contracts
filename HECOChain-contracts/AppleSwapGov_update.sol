// SPDX-License-Identifier: GPL
pragma solidity 0.6.12;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function mint(address account, uint256 amount) external returns (bool);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IAppleSwapBlackList {
    // event OwnerChanged(address);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event AddedBlackLists(address[]);
    event RemovedBlackLists(address[]);

    function owner()external view returns (address);
    // function newOwner()external view returns (address);
    function isBlackListed(address)external view returns (bool);

    // function changeOwner(address ownerToSet) external;
    // function updateOwner() external;
    function transferOwnership(address newOwner) external;
    function addBlackLists(address[] calldata  accounts)external;
    function removeBlackLists(address[] calldata  accounts)external;
}

interface IAppleWhiteList {
    event AppendWhiter(address adder);
    event RemoveWhiter(address remover);
    
    function appendWhiter(address account) external;
    function removeWhiter(address account) external;
    function isWhiter(address account) external;
    function isNotWhiter(address account) external;
}

interface IAppleSwapToken is IERC20, IAppleSwapBlackList{
    function burn(uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    // function multiTransfer(uint256[] calldata mixedAddrVal) external returns (bool);
    function batchTransfer(address[] memory addressList, uint256[] memory amountList) external returns (bool);
}

interface IAppleSwapGov {
    event NewFundsProposal  (uint64 proposalID, string title, string desc, string url, uint32 deadline, address beneficiary, uint256 amount);
    event NewParamProposal  (uint64 proposalID, string title, string desc, string url, uint32 deadline, address factory, uint32 feeBPS);
    event NewUpgradeProposal(uint64 proposalID, string title, string desc, string url, uint32 deadline, address factory, address pairLogic);
    event NewTextProposal   (uint64 proposalID, string title, string desc, string url, uint32 deadline);
    event NewMintProposal   (uint64 proposalID, string title, string desc, string url, uint32 deadline, address mintTo, uint256 mintAmt);
    event NewVote(uint64 proposalID, address voter, uint8 opinion, uint112 voteAmt);
    event AddVote(uint64 proposalID, address voter, uint8 opinion, uint112 voteAmt);
    event Revote (uint64 proposalID, address voter, uint8 opinion, uint112 voteAmt);
    event TallyResult(uint64 proposalID, bool pass);

    function appleContract() external pure returns (address);
    function proposalInfo() external view returns (
            uint24 id, address proposer, uint8 _type, uint32 deadline, address addr, uint256 value,
            uint112 totalYes, uint112 totalNo, uint112 totalDeposit);
    function voterInfo(address voter) external view returns (
            uint24 votedProposalID, uint8 votedOpinion, uint112 votedAmt, uint112 depositedAmt);

    function submitFundsProposal  (string calldata title, string calldata desc, string calldata url, address beneficiary, uint256 fundsAmt, uint112 voteAmt) external;
    function submitParamProposal  (string calldata title, string calldata desc, string calldata url, address factory, uint32 feeBPS, uint112 voteAmt) external;
    function submitUpgradeProposal(string calldata title, string calldata desc, string calldata url, address factory, address pairLogic, uint112 voteAmt) external;
    function submitTextProposal   (string calldata title, string calldata desc, string calldata url, uint112 voteAmt) external;
    function submitMintProposal(string calldata title, string calldata desc, string calldata url, address mintTo, uint256 mintAmt, uint112 voteAmt) external;
    function vote(uint8 opinion, uint112 voteAmt) external;
    function tally() external;
    function withdrawApples(uint112 amt) external;
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

contract AppleSwapGov is IAppleSwapGov {

    struct VoterInfo {
        uint24  votedProposal;
        uint8   votedOpinion;
        uint112 votedAmt;     // enouth to store Apples
        uint112 depositedAmt; // enouth to store Apples
    }

    uint8   private constant _PROPOSAL_TYPE_FUNDS   = 1; // ask for funds
    uint8   private constant _PROPOSAL_TYPE_PARAM   = 2; // change factory.feeBPS
    uint8   private constant _PROPOSAL_TYPE_UPGRADE = 3; // change factory.pairLogic
    uint8   private constant _PROPOSAL_TYPE_TEXT    = 4; // pure text proposal
    uint8   private constant _PROPOSAL_TYPE_MINT    = 5;// mint tokens to specified address //TODO: specify address

    uint8   private constant _YES = 1;
    uint8   private constant _NO  = 2;
    uint32  private constant _MIN_FEE_BPS = 0;
    uint32  private constant _MAX_FEE_BPS = 50;
    uint256 private constant _MAX_FUNDS_REQUEST = 5000000; // 5000000 Apples
    uint256 private constant _FAILED_PROPOSAL_COST = 1000; //    1000 Apples
    uint256 private constant _SUBMIT_APPLES_PERCENT = 1; // 0.1%
    uint256 private constant _VOTE_PERIOD = 3 days;
    uint256 private constant _TEXT_PROPOSAL_INTERVAL = 1 days;
    uint256 private constant _MINT_PROPOSAL_LIMIT = 10000000 * (10**18) ; // mint limitation //TODO: modify amount

    address public  immutable override appleContract;
    uint256 private immutable _maxFundsRequest;    // 5000000 Apples
    uint256 private immutable _failedProposalCost; //    1000 Apples

    uint24  private _proposalID;
    uint8   private _proposalType; // FUNDS            | PARAM        | UPGRADE            | TEXT
    uint32  private _deadline;     // unix timestamp   | same         | same               | same
    address private _addr;         // beneficiary addr | factory addr | factory addr       | not used
    uint256 private _value;        // amount of funds  | feeBPS       | pair logic address | not used
    address private _proposer;
    uint112 private _totalYes;
    uint112 private _totalNo;
    uint112 private _totalDeposit;
    mapping (address => VoterInfo) private _voters;

    constructor(address _appleContract) public {
        appleContract = _appleContract;
        uint256 ApplesDec = IERC20(_appleContract).decimals();
        _maxFundsRequest = _MAX_FUNDS_REQUEST * (10 ** ApplesDec);
        _failedProposalCost = _FAILED_PROPOSAL_COST * (10 ** ApplesDec);
    }

    function proposalInfo() external view override returns (
            uint24 id, address proposer, uint8 _type, uint32 deadline, address addr, uint256 value,
            uint112 totalYes, uint112 totalNo, uint112 totalDeposit) {
        id           = _proposalID;
        proposer     = _proposer;
        _type        = _proposalType;
        deadline     = _deadline;
        value        = _value;
        addr         = _addr;
        totalYes     = _totalYes;
        totalNo      = _totalNo;
        totalDeposit = _totalDeposit;
    }
    function voterInfo(address voter) external view override returns (
            uint24 votedProposalID, uint8 votedOpinion, uint112 votedAmt, uint112 depositedAmt) {
        VoterInfo memory info = _voters[voter];
        votedProposalID = info.votedProposal;
        votedOpinion    = info.votedOpinion;
        votedAmt        = info.votedAmt;
        depositedAmt    = info.depositedAmt;
    }

    // submit new proposals
    function submitFundsProposal(string calldata title, string calldata desc, string calldata url,
            address beneficiary, uint256 fundsAmt, uint112 voteAmt) external override {
        if (fundsAmt > 0) {
            require(fundsAmt <= _maxFundsRequest, "AppleSwapGov: ASK_TOO_MANY_FUNDS");
            uint256 govApples = IERC20(appleContract).balanceOf(address(this));
            uint256 availableApples = govApples - _totalDeposit;
            require(govApples > _totalDeposit && availableApples >= fundsAmt,
                "AppleSwapGov: INSUFFICIENT_FUNDS");
        }
        _newProposal(_PROPOSAL_TYPE_FUNDS, beneficiary, fundsAmt, voteAmt);
        emit NewFundsProposal(_proposalID, title, desc, url, _deadline, beneficiary, fundsAmt);
        _vote(_YES, voteAmt);
    }
    function submitParamProposal(string calldata title, string calldata desc, string calldata url,
            address factory, uint32 feeBPS, uint112 voteAmt) external override {
        require(feeBPS >= _MIN_FEE_BPS && feeBPS <= _MAX_FEE_BPS, "AppleSwapGov: INVALID_FEE_BPS");
        _newProposal(_PROPOSAL_TYPE_PARAM, factory, feeBPS, voteAmt);
        emit NewParamProposal(_proposalID, title, desc, url, _deadline, factory, feeBPS);
        _vote(_YES, voteAmt);
    }
    function submitUpgradeProposal(string calldata title, string calldata desc, string calldata url,
            address factory, address pairLogic, uint112 voteAmt) external override {
        require(pairLogic != address(0), "AppleSwapGov: INVALID_PAIR_LOGIC");
        _newProposal(_PROPOSAL_TYPE_UPGRADE, factory, uint256(pairLogic), voteAmt);
        emit NewUpgradeProposal(_proposalID, title, desc, url, _deadline, factory, pairLogic);
        _vote(_YES, voteAmt);
    }
    function submitTextProposal(string calldata title, string calldata desc, string calldata url,
            uint112 voteAmt) external override {
        // solhint-disable-next-line not-rely-on-time
        require(uint256(_deadline) + _TEXT_PROPOSAL_INTERVAL < block.timestamp,
            "AppleSwapGov: COOLING_DOWN");
        _newProposal(_PROPOSAL_TYPE_TEXT, address(0), 0, voteAmt);
        emit NewTextProposal(_proposalID, title, desc, url, _deadline);
        _vote(_YES, voteAmt);
    }

    function submitMintProposal(string calldata title, string calldata desc, string calldata url, address mintTo, 
            uint256 mintAmt, uint112 voteAmt) external override {
        require(mintTo != address(0) && mintAmt <= _MINT_PROPOSAL_LIMIT, "AppleSwapGov: INVALID_ADDRESS_OR_AMOUNT");
        _newProposal(_PROPOSAL_TYPE_MINT, mintTo, mintAmt, voteAmt);
        emit NewMintProposal(_proposalID, title, desc, url, _deadline, mintTo, mintAmt);
        _vote(_YES, voteAmt);
    }

    function _newProposal(uint8 _type, address addr, uint256 value, uint112 voteAmt) private {
        require(_type >= _PROPOSAL_TYPE_FUNDS && _type <= _PROPOSAL_TYPE_MINT,
            "AppleSwapGov: INVALID_PROPOSAL_TYPE");
        require(_type == _PROPOSAL_TYPE_TEXT || msg.sender == IAppleSwapToken(appleContract).owner(),
            "AppleSwapGov: NOT_APPLES_OWNER");
        require(_proposalType == 0, "AppleSwapGov: LAST_PROPOSAL_NOT_FINISHED");

        uint256 totalApples = IERC20(appleContract).totalSupply();
        uint256 thresApples = (totalApples/1000) * _SUBMIT_APPLES_PERCENT;
        require(voteAmt >= thresApples, "AppleSwapGov: VOTE_AMOUNT_TOO_LESS");

        _proposalID++;
        _proposalType = _type;
        _proposer = msg.sender;
        // solhint-disable-next-line not-rely-on-time
        _deadline = uint32(block.timestamp + _VOTE_PERIOD);
        _value = value;
        _addr = addr;
        _totalYes = 0;
        _totalNo = 0;
    }
 
    function vote(uint8 opinion, uint112 voteAmt) external override {
        require(_proposalType > 0, "AppleSwapGov: NO_PROPOSAL");
        // solhint-disable-next-line not-rely-on-time
        require(uint256(_deadline) > block.timestamp, "AppleSwapGov: DEADLINE_REACHED");
        _vote(opinion, voteAmt);
    }

    function _vote(uint8 opinion, uint112 addedVoteAmt) private {
        require(_YES <= opinion && opinion <= _NO, "AppleSwapGov: INVALID_OPINION");
        require(addedVoteAmt > 0, "AppleSwapGov: ZERO_VOTE_AMOUNT");

        (uint24 currProposalID, uint24 votedProposalID,
            uint8 votedOpinion, uint112 votedAmt, uint112 depositedAmt) = _getVoterInfo();

        // cancel previous votes if opinion changed
        bool isRevote = false;
        if ((votedProposalID == currProposalID) && (votedOpinion != opinion)) {
            if (votedOpinion == _YES) {
                assert(_totalYes >= votedAmt);
                _totalYes -= votedAmt;
            } else {
                assert(_totalNo >= votedAmt);
                _totalNo -= votedAmt;
            }
            votedAmt = 0;
            isRevote = true;
        }

        // need to deposit more Apples?
        assert(depositedAmt >= votedAmt);
        if (addedVoteAmt > depositedAmt - votedAmt) {
            uint112 moreDeposit = addedVoteAmt - (depositedAmt - votedAmt);
            depositedAmt += moreDeposit;
            _totalDeposit += moreDeposit;
            IERC20(appleContract).transferFrom(msg.sender, address(this), moreDeposit);
        }

        if (opinion == _YES) {
            _totalYes += addedVoteAmt;
        } else {
            _totalNo += addedVoteAmt;
        }
        votedAmt += addedVoteAmt;
        _setVoterInfo(currProposalID, opinion, votedAmt, depositedAmt);
 
        if (isRevote) {
            emit Revote(currProposalID, msg.sender, opinion, addedVoteAmt);
        } else if (votedAmt > addedVoteAmt) {
            emit AddVote(currProposalID, msg.sender, opinion, addedVoteAmt);
        } else {
            emit NewVote(currProposalID, msg.sender, opinion, addedVoteAmt);
        }
    }
    function _getVoterInfo() private view returns (uint24 currProposalID,
            uint24 votedProposalID, uint8 votedOpinion, uint112 votedAmt, uint112 depositedAmt) {
        currProposalID = _proposalID;
        VoterInfo memory voter = _voters[msg.sender];
        depositedAmt = voter.depositedAmt;
        if (voter.votedProposal == currProposalID) {
            votedProposalID = currProposalID;
            votedOpinion = voter.votedOpinion;
            votedAmt = voter.votedAmt;
        }
    }
    function _setVoterInfo(uint24 proposalID,
            uint8 opinion, uint112 votedAmt, uint112 depositedAmt) private {
        _voters[msg.sender] = VoterInfo({
            votedProposal: proposalID,
            votedOpinion : opinion,
            votedAmt     : votedAmt,
            depositedAmt : depositedAmt
        });
    }

    function tally() external override {
        require(_proposalType > 0, "AppleSwapGov: NO_PROPOSAL");
        // solhint-disable-next-line not-rely-on-time
        require(uint256(_deadline) <= block.timestamp, "AppleSwapGov: STILL_VOTING");

        bool ok = _totalYes > _totalNo;
        uint8 _type = _proposalType;
        uint256 val = _value;
        address addr = _addr;
        address proposer = _proposer;
        _resetProposal();
        if (ok) {
            _execProposal(_type, addr, val);
        } else {
            _taxProposer(proposer);
        }
        emit TallyResult(_proposalID, ok);
    }
    function _resetProposal() private {
        _proposalType = 0;
     // _deadline     = 0; // use _deadline to check _TEXT_PROPOSAL_INTERVAL
        _value        = 0;
        _addr         = address(0);
        _proposer     = address(0);
        _totalYes     = 0;
        _totalNo      = 0;
    }
    function _execProposal(uint8 _type, address addr, uint256 val) private {
        if (_type == _PROPOSAL_TYPE_FUNDS) {
            if (val > 0) {
                IERC20(appleContract).transfer(addr, val);
            }
        } else if (_type == _PROPOSAL_TYPE_PARAM) {
            IAppleSwapFactory(addr).setFeeBPS(uint32(val));
        } else if (_type == _PROPOSAL_TYPE_UPGRADE) {
            IAppleSwapFactory(addr).setPairLogic(address(val));
        } else if (_type == _PROPOSAL_TYPE_MINT) {
            IERC20(appleContract).mint(addr, val);
        }
    }
    function _taxProposer(address proposerAddr) private {
        // burn 1000 Apples of proposer
        uint112 cost = uint112(_failedProposalCost);

        VoterInfo memory proposerInfo = _voters[proposerAddr];
        if (proposerInfo.depositedAmt < cost) { // unreachable!
            cost = proposerInfo.depositedAmt;
        }

        _totalDeposit -= cost;
        proposerInfo.depositedAmt -= cost;
        _voters[proposerAddr] = proposerInfo;

        IAppleSwapToken(appleContract).burn(cost);
    }

    function withdrawApples(uint112 amt) external override {
        VoterInfo memory voter = _voters[msg.sender];

        require(_proposalType == 0 || voter.votedProposal < _proposalID, "AppleSwapGov: IN_VOTING");
        require(amt > 0 && amt <= voter.depositedAmt, "AppleSwapGov: INVALID_WITHDRAW_AMOUNT");

        _totalDeposit -= amt;
        voter.depositedAmt -= amt;
        if (voter.depositedAmt == 0) {
            delete _voters[msg.sender];
        } else {
            _voters[msg.sender] = voter;
        }
        IERC20(appleContract).transfer(msg.sender, amt);
    }

}
