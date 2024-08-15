// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
// 存钱罐合约
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IERC721 {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract Bank {
    // 状态变量
    address public immutable owner;
    bool private disabled;

    // 事件
    event Deposit(address indexed _ads, uint256 amount);
    event WithdrawETH(uint256 amount);
    event WithdrawERC20(address token, uint256 amount);
    event WithdrawERC721(address token, uint256 tokenId);

    // 修饰符
    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner");
        _;
    }

    modifier isEnabled() {
        require(!disabled, "Contract is disabled");
        _;
    }

    // 接收以太币
    receive() external payable isEnabled {
        emit Deposit(msg.sender, msg.value);
    }

    // 构造函数
    constructor() payable {
        owner = msg.sender;
        disabled = false;
    }

    // 提取所有资产的方法
    function withdrawAllAssets(address[] calldata erc20Tokens, address[] calldata erc721Tokens, uint256[] calldata erc721TokenIds) external onlyOwner isEnabled {
        require(erc721Tokens.length == erc721TokenIds.length, "ERC721 tokens and IDs length mismatch");

        // 提取以太币
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            emit WithdrawETH(ethBalance);
            payable(msg.sender).transfer(ethBalance);
        }

        // 提取ERC20代币
        for (uint i = 0; i < erc20Tokens.length; i++) {
            IERC20 erc20 = IERC20(erc20Tokens[i]);
            uint256 balance = erc20.balanceOf(address(this));
            if (balance > 0) {
                require(erc20.transfer(msg.sender, balance), "Transfer failed");
                emit WithdrawERC20(erc20Tokens[i], balance);
            }
        }

        // 提取ERC721代币
        for (uint i = 0; i < erc721Tokens.length; i++) {
            IERC721 erc721 = IERC721(erc721Tokens[i]);
            require(erc721.ownerOf(erc721TokenIds[i]) == address(this), "Not owner of token");
            erc721.transferFrom(address(this), msg.sender, erc721TokenIds[i]);
            emit WithdrawERC721(erc721Tokens[i], erc721TokenIds[i]);
        }

        disabled = true;
        selfdestruct(payable(msg.sender));
    }

    // 查看以太币余额
    function getBalanceETH() external view returns (uint256) {
        return address(this).balance;
    }

    // 查看指定ERC20代币余额
    function getBalanceERC20(address token) external view returns (uint256) {
        IERC20 erc20 = IERC20(token);
        return erc20.balanceOf(address(this));
    }

    // 检查是否拥有指定ERC721代币
    function isOwnerOfERC721(address token, uint256 tokenId) external view returns (bool) {
        IERC721 erc721 = IERC721(token);
        return erc721.ownerOf(tokenId) == address(this);
    }
}
