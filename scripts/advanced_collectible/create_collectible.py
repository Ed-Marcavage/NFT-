from brownie import AdvancedCollectible, accounts, config
from scripts.helpful_scripts import get_breed, fund_with_link
import time

STATIC_SEED = 123

def main():
    dev = accounts.add(config["wallets"]["from_key"])
    advanced_collectible = AdvancedCollectible[len(AdvancedCollectible) - 1]
    # fund_with_link(advanced_collectible.address, dev)
    #createCollectible(string memory tokenURI)
    transaction = advanced_collectible.createCollectible("None", {"from": dev})
    transaction.wait(1)
    requestId = transaction.events["RequestedCollectible"]["requestId"]
    token_id = advanced_collectible.requestIdToTokenId(requestId)
    breed = get_breed(advanced_collectible.tokenIdToBreed(token_id))
    print("Dog breed of tokenId {} is {}".format(token_id, breed))