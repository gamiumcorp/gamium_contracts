// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./GamiumToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20Contract {
  function mint(address _to, uint256 _amount) external;
}

contract GamiumAllocator  is Ownable {
    event ERC20Released(string category, address to, uint256 amount);
    
    // total distributed
    uint public totalMinted;

    // token contract
    address public tokenContract;

    // Distribution structure
    struct Distribution {
        address  _beneficiary;
        uint _tgeAmount;
        uint _linearAmount;
        uint64 _start;
        uint64 _duration;
    }

    // UNIX dates
    uint64 private constant _Dec_12_2021_1500 = 1_639_321_200; // TGE
    uint64 private constant _Mar_12_2022_1500 = 1_647_097_200; // Month 3
    uint64 private constant _Jun_12_2022_1500 = 1_655_046_000; // Month 6

    // durations
    uint64 private constant _0_months = 0; // 0 months
    uint64 private constant _6_months = 15_780_000; // 6 months
    uint64 private constant _12_months = 31_560_000; // 12 months
    uint64 private constant _24_months = 63_120_000; // 24 months

    // addresses
    address public constant airdropAddress = 0xA6f5c0a236718243313652231A0AcA6fe6751611;
    address public constant seedAddress = 0xA6f5c0a236718243313652231A0AcA6fe6751611;
    address public constant privateAddress = 0xA6f5c0a236718243313652231A0AcA6fe6751611;
    address public constant publicAddress = 0xA6f5c0a236718243313652231A0AcA6fe6751611;
    address public constant advisorsAddress = 0xA6f5c0a236718243313652231A0AcA6fe6751611;
    address public constant stakingAddress = 0xA6f5c0a236718243313652231A0AcA6fe6751611;
    address public constant liquidityAddress = 0xA6f5c0a236718243313652231A0AcA6fe6751611;
    address public constant treasuryAddress = 0xA6f5c0a236718243313652231A0AcA6fe6751611;
    address public constant marketingAddress = 0xA6f5c0a236718243313652231A0AcA6fe6751611;
    address public constant teamAddress = 0xA6f5c0a236718243313652231A0AcA6fe6751611;
    address public constant exchangesReserveAddress = 0xA6f5c0a236718243313652231A0AcA6fe6751611;

    // decimal base
    uint private constant decimalBase = 1e18;

    // tge distribution values
    uint private constant airdropTGEValue = 25_000_000 * decimalBase;
    uint private constant seedTGEValue = 50_000_000 * decimalBase;
    uint private constant privateTGEValue = 100_000_000 * decimalBase;
    uint private constant publicTGEValue = 50_000_000 * decimalBase;
    uint private constant advisorsTGEValue = 0 * decimalBase; 
    uint private constant stakingTGEValue = 0 * decimalBase; 
    uint private constant liquidityTGEValue = 1_000_000_000 * decimalBase;
    uint private constant treasuryTGEValue = 660_000_000 * decimalBase; 
    uint private constant marketingTGEValue = 380_000_000 * decimalBase;
    uint private constant teamTGEValue = 0 * decimalBase;
    uint private constant exchangesTGEValue = 1_000_000_000 * decimalBase;

    // linear distribution values
    uint private constant airdropLinearValue = 475_000_000 * decimalBase; // 500M (TOTAL) - 5% TGE
    uint private constant seedLinearValue = 950_000_000 * decimalBase; // 1000M (TOTAL) - 5% TGE
    uint private constant privateLinearValue = 1_900_000_000 * decimalBase; // 2000M (TOTAL) - 5% TGE
    uint private constant publicLinearValue = 950_000_000 * decimalBase; // 1000M (TOTAL) - 5% TGE
    uint private constant advisorsLinearValue = 1_000_000_000 * decimalBase; // 1000M (TOTAL)
    uint private constant stakingLinearValue = 7_000_000_000 * decimalBase; // 7000M (TOTAL)
    uint private constant liquidityLinearValue = 0 * decimalBase; // 0
    uint private constant treasuryLinearValue = 15_840_000_000 * decimalBase; // 16500M (TOTAL) - 4% TGE
    uint private constant marketingLinearValue = 9_120_000_000 * decimalBase; // 9500M (TOTAL) - 4% TGE
    uint private constant teamLinearValue = 9_500_000_000 * decimalBase; // 9500M (TOTAL) 
    uint private constant exchangesLinearValue = 0 * decimalBase; // 0

    // creating linear distributions config
    Distribution private _airdrop = Distribution(airdropAddress, airdropTGEValue, airdropLinearValue, _Dec_12_2021_1500, _6_months);
    Distribution private _seed = Distribution(seedAddress, seedTGEValue, seedLinearValue, _Dec_12_2021_1500, _24_months);
    Distribution private _private = Distribution(privateAddress, privateTGEValue, privateLinearValue, _Dec_12_2021_1500, _24_months);
    Distribution private _public = Distribution(publicAddress, publicTGEValue, publicLinearValue, _Dec_12_2021_1500, _12_months);
    Distribution private _advisors = Distribution(advisorsAddress, advisorsTGEValue, advisorsLinearValue, _Jun_12_2022_1500, _24_months);
    Distribution private _staking = Distribution(stakingAddress, stakingTGEValue, stakingLinearValue, _Mar_12_2022_1500, _24_months);
    Distribution private _liquidity = Distribution(liquidityAddress, liquidityTGEValue, liquidityLinearValue, _Dec_12_2021_1500, _0_months);
    Distribution private _treasury = Distribution(treasuryAddress, treasuryTGEValue, treasuryLinearValue, _Dec_12_2021_1500, _24_months);
    Distribution private _marketing = Distribution(marketingAddress, marketingTGEValue, marketingLinearValue, _Dec_12_2021_1500, _24_months);
    Distribution private _team = Distribution(teamAddress, teamTGEValue, teamLinearValue, _Jun_12_2022_1500, _24_months);
    Distribution private _exchanges = Distribution(exchangesReserveAddress, exchangesTGEValue, exchangesLinearValue, _Dec_12_2021_1500, _0_months);

    // categories of tokenomics
    string[11] private constant categories = ["Airdrop", "Seed", "Private", "Public", "Advisors", "Staking", "Liquidity", "Treasury", "Marketing", "Team", "Exchanges"];
    
    // Distributions mapping depending on the category
    mapping(string => uint) public GMMReleased;
    mapping(string => uint8) private _categoriesMap;
    mapping(string => bool) private _categoryExist;

    // Distributions array
    Distribution[11] private _distributions;

    constructor(address _tokenContract) {
        tokenContract = _tokenContract;
        _setDefaultValues();
    }

    /**
     * @dev Set up arrays and mappings.
     */
    function _setDefaultValues() private {
        _distributions[0] = _airdrop;
        _distributions[1] = _seed;
        _distributions[2] = _private;
        _distributions[3] = _public;
        _distributions[4] = _advisors;
        _distributions[5] = _staking;
        _distributions[6] = _liquidity;
        _distributions[7] = _treasury;
        _distributions[8] = _marketing;
        _distributions[9] = _team;
        _distributions[10] = _exchanges;
        
        _categoriesMap["Airdrop"] = 0;
        _categoriesMap["Seed"] = 1;
        _categoriesMap["Private"] = 2;
        _categoriesMap["Public"] = 3;
        _categoriesMap["Advisors"] = 4;
        _categoriesMap["Staking"] = 5;
        _categoriesMap["Liquidity"] = 6;
        _categoriesMap["Treasury"] = 7;
        _categoriesMap["Marketing"] = 8;
        _categoriesMap["Team"] = 9;
        _categoriesMap["Exchanges"] = 10;
        
        _categoryExist["Airdrop"] = true;
        _categoryExist["Seed"] = true;
        _categoryExist["Private"] = true;
        _categoryExist["Public"] = true;
        _categoryExist["Advisors"] = true;
        _categoryExist["Staking"] = true;
        _categoryExist["Liquidity"] = true;
        _categoryExist["Treasury"] = true;
        _categoryExist["Marketing"] = true;
        _categoryExist["Team"] = true;
        _categoryExist["Exchanges"] = true;
    }

    /**
     * @dev Mint tokenContract tokens.
     *
     * Emits a {ERC20Released} event.
     */
     function mintTokens(address beneficiary, uint256 releasable, string memory category) private {
        if (releasable > 0) {
            IERC20Contract gmmContract = IERC20Contract(tokenContract);

            GMMReleased[category] += releasable;
            totalMinted += releasable;
            gmmContract.mint(beneficiary, releasable);
            emit ERC20Released(category, beneficiary, releasable);
        }
     }

    /**
     * @dev Release the tokens used for liquidity and exchanges reserve.
     *
     * Emits a {ERC20Released} event.
     */
    function unlockLiquidity() external onlyOwner {
        uint256 releasableLiquidity = categoryReleasable("Liquidity");
        mintTokens(liquidityAddress, releasableLiquidity, "Liquidity");

        uint256 releasableExchanges = categoryReleasable("Exchanges");
        mintTokens(exchangesReserveAddress, releasableExchanges, "Exchanges");
    }

    /**
     * @dev Release all the tokens that are releasable.
     *
     * Emits a {ERC20Released} event.
     */
    function releaseTokens() external virtual {
        require(_Dec_12_2021_1500 < uint64(block.timestamp), "TGE event did not start yet");

        for (uint i = 0; i < categories.length; i++) {
            address beneficiary = _distributions[i]._beneficiary;
            uint256 releasable = categoryReleasable(categories[i]);

            mintTokens(beneficiary, releasable, categories[i]);
        }
    }
    
    /**
     * @dev Calculates the amount of tokens that are releasable for certain category.
     */
    function categoryReleasable(string memory _category) public view virtual returns (uint256) {
        require(_categoryExist[_category], "Category does not exist");
        uint8 i = _categoriesMap[_category];
        
        uint tgeAmount = _distributions[i]._tgeAmount;
        uint linearAmount = _distributions[i]._linearAmount;
        uint64 start = _distributions[i]._start;
        uint64 duration = _distributions[i]._duration;
        
        uint256 vestingReleasable = _vestingSchedule(start, duration, linearAmount, uint64(block.timestamp));
        uint256 releasable = vestingReleasable + tgeAmount - GMMReleased[_category];
        return releasable;
    }

    /**
     * @dev Virtual implementation of the vesting formula. This returns the amout vested, as a function of time, for
     * an asset given its total historical allocation.
       check https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/finance/VestingWallet.sol
     */
    function _vestingSchedule(uint64 start, uint64 duration, uint linearAllocation, uint64 timestamp) internal view virtual returns (uint256) {
        if (timestamp < start) {
            return 0;
        } else if (timestamp > start + duration) {
            return linearAllocation;
        } else {
            return (linearAllocation * (timestamp - start)) / duration;
        }
    }
}