// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC/ERC.sol)

pragma solidity ^0.8.0;

import "./interfaces/IERC.sol";
import "./interfaces/IERCReceiver.sol";
import "./Dependencies/Address.sol";
import "./Dependencies/Context.sol";
import "./Dependencies/Strings.sol";
import "./Dependencies/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERCEnumerable}.
 */
contract ERC is Context, ERC165, IERC {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(bytes  => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(bytes  => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }



    /**
     * @dev See {IERC-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC-ownerOf}.
     */
    function ownerOf(bytes memory dataHash) public view virtual override returns (address) {
        address owner = _owners[dataHash];
        require(owner != address(0), "ERC: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERCMetadata-name}.
     */
    function name() public view virtual  returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERCMetadata-symbol}.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }


    /**
     * @dev See {IERC-approve}.
     */
    function approve(address to, bytes memory dataHash) public virtual override {
        address owner = ERC.ownerOf(dataHash);
        require(to != owner, "ERC: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC: approve caller is not owner nor approved for all"
        );

        _approve(to, dataHash);
    }

    /**
     * @dev See {IERC-getApproved}.
     */
    function getApproved(bytes memory dataHash) public view virtual override returns (address) {
        require(_exists(dataHash), "ERC: approved query for nonexistent token");

        return _tokenApprovals[dataHash];
    }

    /**
     * @dev See {IERC-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        bytes memory dataHash
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), dataHash), "ERC: transfer caller is not owner nor approved");

        _transfer(from, to, dataHash);
    }

    /**
     * @dev See {IERC-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        bytes memory dataHash
    ) public virtual override {
        safeTransferFrom(from, to, dataHash, "");
    }

    /**
     * @dev See {IERC-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        bytes memory dataHash,
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), dataHash), "ERC: transfer caller is not owner nor approved");
        _safeTransfer(from, to, dataHash, data);
    }

    /**
     * @dev Safely transfers `dataHash` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `dataHash` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERCReceiver-onERCReceived}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        bytes memory dataHash,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, dataHash);
        require(_checkOnERCReceived(from, to, dataHash, data), "ERC: transfer to non ERCReceiver implementer");
    }

    /**
     * @dev Returns whether `dataHash` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(bytes memory dataHash) internal view virtual returns (bool) {
        return _owners[dataHash] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `dataHash`.
     *
     * Requirements:
     *
     * - `dataHash` must exist.
     */
    function _isApprovedOrOwner(address spender, bytes memory dataHash) internal view virtual returns (bool) {
        require(_exists(dataHash), "ERC: operator query for nonexistent token");
        address owner = ERC.ownerOf(dataHash);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(dataHash) == spender);
    }

    /**
     * @dev Safely mints `dataHash` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `dataHash` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERCReceiver-onERCReceived}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, bytes memory dataHash) internal virtual {
        _safeMint(to, dataHash, "");
    }

    /**
     * @dev Same as {xref-ERC-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERCReceiver-onERCReceived} to contract recipients.
     */
    function _safeMint(
        address to,
        bytes memory dataHash,
        bytes memory data
    ) internal virtual {
        _mint(to, dataHash);
        require(
            _checkOnERCReceived(address(0), to, dataHash, data),
            "ERC: transfer to non ERCReceiver implementer"
        );
    }

    /**
     * @dev Mints `dataHash` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `dataHash` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, bytes memory dataHash) internal virtual {
        require(to != address(0), "ERC: mint to the zero address");
        require(!_exists(dataHash), "ERC: token already minted");

        _beforeTokenTransfer(address(0), to, dataHash);

        _balances[to] += 1;
        _owners[dataHash] = to;

        emit Transfer(address(0), to, dataHash);

        _afterTokenTransfer(address(0), to, dataHash);
    }

    /**
     * @dev Destroys `dataHash`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `dataHash` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(bytes memory dataHash) internal virtual {
        address owner = ERC.ownerOf(dataHash);

        _beforeTokenTransfer(owner, address(0), dataHash);

        // Clear approvals
        _approve(address(0), dataHash);

        _balances[owner] -= 1;
        delete _owners[dataHash];

        emit Transfer(owner, address(0), dataHash);

        _afterTokenTransfer(owner, address(0), dataHash);
    }

    /**
     * @dev Transfers `dataHash` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `dataHash` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        bytes memory dataHash
    ) internal virtual {
        require(ERC.ownerOf(dataHash) == from, "ERC: transfer from incorrect owner");
        require(to != address(0), "ERC: transfer to the zero address");

        _beforeTokenTransfer(from, to, dataHash);

        // Clear approvals from the previous owner
        _approve(address(0), dataHash);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[dataHash] = to;

        emit Transfer(from, to, dataHash);

        _afterTokenTransfer(from, to, dataHash);
    }

    /**
     * @dev Approve `to` to operate on `dataHash`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, bytes memory dataHash) internal virtual {
        _tokenApprovals[dataHash] = to;
        emit Approval(ERC.ownerOf(dataHash), to, dataHash);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }


    function _update(address to ,bytes memory dataHash)internal virtual{
        require(to != address(0), "ERC: mint to the zero address");
        require(_exists(dataHash), "can only update existing tokens ");
        _burn( dataHash);
        _safeMint(to, dataHash, "");
        emit Updated(to, dataHash);

    }

    function update(address to, bytes memory dataHash) public virtual override {
       _update(to ,dataHash) ;
    }

    

    /**
     * @dev Internal function to invoke {IERCReceiver-onERCReceived} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param dataHash uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERCReceived(
        address from,
        address to,
        bytes memory dataHash,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERCReceiver(to).onERCReceived(_msgSender(), from, dataHash, data) returns (bytes4 retval) {
                return retval == IERCReceiver.onERCReceived.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC: transfer to non ERCReceiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `dataHash` will be
     * transferred to `to`.
     * - When `from` is zero, `dataHash` will be minted for `to`.
     * - When `to` is zero, ``from``'s `dataHash` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        bytes memory dataHash
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        bytes memory dataHash
    ) internal virtual {}
}