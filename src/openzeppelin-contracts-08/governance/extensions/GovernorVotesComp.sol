// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (governance/extensions/GovernorVotesComp.sol)

pragma solidity ^0.8.0;

import "../Governor.sol";
import "../../token/ERC20/extensions/ERC20VotesComp.sol";

/**
 * @dev Extension of {Governor} for voting weight extraction from a Comp token.
 *
 * _Available since v4.3._
 */
abstract contract GovernorVotesComp is Governor {
    ERC20VotesComp public immutable token;

    constructor(ERC20VotesComp token_) {
        token = token_;
    }

    /**
     * Read the voting weight from the token's built in snapshot mechanism (see {Governor-_getVotes}).
     */
    function _getVotes(address account, uint256 blockNumber, bytes memory /*params*/ )
        internal
        view
        virtual
        override
        returns (uint256)
    {
        return token.getPriorVotes(account, blockNumber);
    }
}
