## Para poder realizar el test hay que tener en cuenta las siguiente consideraciones:

- La siguiente variables del archivo staking.sol deben cambiar de private a public:

- Variables que corresponden al owner

```solidity
uint256 private contractBalance;
address private immutable owner;
```

- Variables almacenan el tiempo permitido por stake

```solidity
uint256 private oneYearStakeTimeStamp;
uint256 private twoYearStakeTimeStamp;
uint256 private threeYearStakeTimeStamp;
```

- Variables almacenan la recompensa segun el año

```solidity
uint256 private rewardForOneYear;
uint256 private rewardForTwoYear;
uint256 private rewardForThreeYear;
```

```solidity
- La función parseNumberToSeconds() debe ser public en lugar de internal.
- La función rewardCalculated() debe ser public en lugar de internal.
```