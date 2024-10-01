# @version 0.3.7

"""
@title Launchpad
@license MIT
"""

votingEscrow: public(immutable(address))
rewardDistributor: public(immutable(address))
rewardFaucet: public(immutable(address))


interface IVotingEscrow:
    def initialize(
        _token: address,
        _name: String[64],
        _symbol: String[32],
        _admin: address,
        _admin_unlock_all: address,
        _maxLockTime: uint256,
    ): nonpayable

interface IRewardDistributor:
    def initialize(
        _veAddress: address,
        _rewardFaucet: address,
        _startTime: uint256,
        _admin: address
    ): nonpayable

interface IRewardFaucet:
    def initialize(
        _rewardDistributor: address,
    ): nonpayable

event VESystemCreated:
    token: indexed(address)
    votingEscrow: address
    rewardDistributor: address
    rewardFaucet: address
    admin: address


@external
def __init__(
    _votingEscrow: address,
    _rewardDistributor: address,
    _rewardFaucet: address,
):
    assert (
        _votingEscrow != empty(address) and
        _rewardDistributor != empty(address) and
        _rewardFaucet != empty(address)
    ), "zero address"

    votingEscrow = _votingEscrow
    rewardDistributor = _rewardDistributor
    rewardFaucet = _rewardFaucet


@external
def deploy(
    tokenAddr: address,
    name: String[64],
    symbol: String[32],
    maxLockTime: uint256,
    rewardDistributorStartTime: uint256,
    admin_unlock_all: address
) -> (address, address, address):
    """
    @notice Deploys new VotingEscrow, RewardDistributor, and RewardFaucet contracts
    @param tokenAddr The address of the token to be used for locking
    @param name The name for the new VotingEscrow contract
    @param symbol The symbol for the new VotingEscrow contract
    @param maxLockTime A constraint for the maximum lock time in the new VotingEscrow contract
    @param rewardDistributorStartTime The start time for reward distribution
    @param admin_unlock_all Admin address to enable unlock-all feature in VotingEscrow
    @return Addresses of the new VotingEscrow, RewardDistributor, and RewardFaucet contracts
    """
    newVotingEscrow: address = create_minimal_proxy_to(votingEscrow)
    newRewardDistributor: address = create_minimal_proxy_to(rewardDistributor)
    newRewardFaucet: address = create_minimal_proxy_to(rewardFaucet)
  
    # Initialize the new VotingEscrow contract
    IVotingEscrow(newVotingEscrow).initialize(
        tokenAddr,
        name,
        symbol,
        msg.sender,
        admin_unlock_all,
        maxLockTime
    )

    # Initialize the RewardDistributor
    IRewardDistributor(newRewardDistributor).initialize(
        newVotingEscrow,
        newRewardFaucet,
        rewardDistributorStartTime,
        msg.sender
    )


    IRewardFaucet(newRewardFaucet).initialize(
        newRewardDistributor
    )

    log VESystemCreated(
        tokenAddr,
        newVotingEscrow,
        newRewardDistributor,
        newRewardFaucet,
        msg.sender
    )

    return (newVotingEscrow, newRewardDistributor, newRewardFaucet)
