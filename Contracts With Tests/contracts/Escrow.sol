// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

interface IERC721 {
    function transferFrom(address _from, address _to, uint256 _nftId) external;
}

contract Escrow {
    address public nftAddress;
    uint256 public nftId;

    address payable seller;
    address payable buyer;
    address public lender;
    address public inspector;

    uint256 public purchasePrice;
    uint256 public escrowAmount;

    bool public inspectionPassed;
    mapping(address => bool) public approval;

    constructor(
        address _nftAddress,
        uint256 _nftId,
        address payable _seller,
        address payable _buyer,
        address payable _inspector,
        address payable _lender,
        uint256 _purchasePrice,
        uint256 _escrowAmount
    ) {
        nftAddress = _nftAddress;
        nftId = _nftId;
        seller = _seller;
        buyer = _buyer;
        inspector = _inspector;
        lender = _lender;
        purchasePrice = _purchasePrice;
        escrowAmount = _escrowAmount;

        inspectionPassed = false;
    }

    modifier onlyBuyer() {
        require(
            msg.sender == buyer,
            "Only Buyer should deposit the Earnest Amount."
        );
        _;
    }

    modifier onlyInspector() {
        require(
            msg.sender == inspector,
            "Only Inspector can call this method."
        );
        _;
    }

    function depositEarnest() public payable onlyBuyer {
        require(
            msg.value >= escrowAmount,
            "The Amount given must be equal to the Escrow Amount."
        );
    }

    function updateInspectionStatus(bool _passed) public onlyInspector {
        inspectionPassed = _passed;
    }

    function approveSale() public {
        approval[msg.sender] = true;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    modifier requireApproveSale() {
        require(approval[buyer], "Buyer need to Approve");
        require(approval[seller], "Seller need to Approve");
        require(approval[lender], "Lender need to Approve");
        _;
    }

    function finalizeSale() public requireApproveSale {
        require(inspectionPassed, "Must pass Inspection.");

        require(address(this).balance >= purchasePrice, "NOt Enough Funds");

        (bool success, ) = payable(seller).call{value: address(this).balance}(
            ""
        );

        require(success, "Failure in Transfer for Funds");

        IERC721(nftAddress).transferFrom(seller, buyer, nftId);
    }

    receive() external payable {}
}
