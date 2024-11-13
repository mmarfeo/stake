// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;



contract Staking {


    // Variables que corrsponden al owner
    uint256 private contractBalance; //debe ser private para el desarrollo y public para el test
    address private immutable owner; //debe ser private para el desarrollo y public para el test

    // Variables almacenan el tiempo permitido por stake
    uint256 private oneYearStakeTimeStamp; //debe ser private para el desarrollo y public para el test
    uint256 private twoYearStakeTimeStamp; //debe ser private para el desarrollo y public para el test
    uint256 private threeYearStakeTimeStamp; //debe ser private para el desarrollo y public para el test

    // Variables almacenan la recompensa segun el año
    uint256 private rewardForOneYear; //debe ser private para el desarrollo y public para el test
    uint256 private rewardForTwoYear; //debe ser private para el desarrollo y public para el test
    uint256 private rewardForThreeYear; //debe ser private para el desarrollo y public para el test

    // Variables dinamicas que almacenan el estado del stake y la recompensa del user.
    uint256 public totalTokensReward;
    uint256 public totalTokensWithdraw;



    // eventos para la distinta logica del contrato
    event InfoStakingReward(string _infoReward, uint256 _rewardPerOneYear);
    event SuccessClaimReward(string _infoReward, uint256 _tokenClaimReward);
    event NotWithdrawAvailable(string _infoReward);
    event unStakeSuccess(string _infoSucessUnstake, uint256 _tokensValue);
    event NotRewardForTimestamp(string _infoNotReward, uint256 _tokenAvailable);
    event UpdateBalanceContract(string _infoUpdate, uint256 _infoBalanceContract);


    // errores para la distinta logica del contrato
    error PlazoInsuficiente();
    error UserNotExist();
    error ContractNotBalance();
    error OnlyOwnerPermission();


    // modificador para controlar funciones que deben ser ejecutadas por el owner
    modifier OnlyOwner() {
        require(owner == msg.sender, OnlyOwnerPermission());
        _;
    }





    constructor(uint256 _contractBalance) {
        owner = msg.sender;
        contractBalance = _contractBalance;

        oneYearStakeTimeStamp = 60;     //  31536000 el valor correcto para que sea 1 años
        twoYearStakeTimeStamp = 120;    //  63072000 el valor correcto para que sea 2 años
        threeYearStakeTimeStamp = 180;  //  94608000 el valor correcto para que sea 3 años

        rewardForOneYear = 25;
        rewardForTwoYear = 50;
        rewardForThreeYear = 75;
    }




    /**
       *  @title UserStakingBody
       *  @notice: Esta estructura servira para almacenar los users que hagan 'stake'
       *  @custom:amountTokenStaked  cantidad de tokens que el usuario stakea
       *  @custom:durationStake  tiempo que el user desea stakear
       *  @custom:blockTimestamp  fecha en la cual el user realizo el stake
       *  @custom:tokenReward  cantidad de tokens que almacenara la recompensa que recibira el user
       *  @custom:exist booleano para comprobar si existe o no el user
     */

    struct UserStakingBody {
        uint256 amountTokenStaked;
        uint256 durationStake;
        uint256 blockTimestamp;
        uint256 tokenReward;
        bool exist;
    }


    /**
        *   @notice StakeTokenUsers
        *   @notice - Mapping para guardar los valores del stake del usuario y su address
    */
    mapping(address => UserStakingBody _stakingBody) public StakeTokensUsers;


    /**
        * @notice parseNumberToSeconds
        * @notice Esta funcion parsea la entrada del parametro para que el usuario no marque el valor en segundos, 
                    no seria amigable. Por lo tanto se ingresan enteros del 1 al 3.
        * @param _num el tiempo que quiere stakear, uno, dos o tres años.
        * @return uint256  // retorna las variables permitidas para el stake en segundos
    */


    function parseNumberToSeconds(uint256 _num) internal view returns (uint256) { //debe ser internal para el desarrollo y public para el test
        if (_num == 1) {
            return oneYearStakeTimeStamp;
        } else if (_num == 2) {
            return twoYearStakeTimeStamp;
        } else if (_num == 3) {
            return threeYearStakeTimeStamp;
        } else {
            revert("Invalid input");
        }
    }




    /**
        * @notice stake
        * @notice funcion que realiza el stake, calcula la duracion en lac condicional y setea la variable reward para
                    almacenarla en el mapping
        * @param _amount cantidad de tokens a stakear
        * @param _duration tiempo que el user quiere hacer el stake
    */

    function stake(uint256 _amount, uint256 _duration) external returns (uint256)   {
        if (_duration < 1 || _duration > 3) {
            revert PlazoInsuficiente();
        }

        uint256 duration = parseNumberToSeconds(_duration);
        

        uint256 reward;

        if (_duration == 1) {
            reward = (_amount / 100) * rewardForOneYear;
        } else if (_duration == 2) {
            reward = (_amount / 100) * rewardForTwoYear;
        } else {
            reward = (_amount / 100) * rewardForThreeYear;
        }

        StakeTokensUsers[msg.sender] = UserStakingBody({
            amountTokenStaked: _amount,
            durationStake: duration,
            blockTimestamp: block.timestamp,
            tokenReward: reward,
            exist: true
        });

        emit InfoStakingReward("Recomponse por este staking", reward);
        return reward;
        
    }




    /**
        * @notice rewardCalculated
        * @notice Funcion para calcular si corresponde o no el reward, debemos usar [msg.sender] en el parametro
        * @param _sender direccion del contrato en formato [msg.sender]
        * @return bool  indica si corresponde o no el reward
    */

    function rewardCalculated(address _sender) internal view returns (bool) { //debe ser internal para el desarrollo y public para el test

        require(StakeTokensUsers[_sender].exist, UserNotExist());

        uint256 endStakeTime = StakeTokensUsers[_sender].durationStake + StakeTokensUsers[_sender].blockTimestamp;

        if (block.timestamp >= endStakeTime) {
            return true;
        } else {
            return false;
        }
    }


    /**
        * @notice  unStake
        * @notice  Funcion que retira el stake del user, dentro usamos la funcion interna "rewardCalculated"
                    para verificar si corresponde o no el reward.
        * @notice  Dentro del primer bloque almacenamos la logica en caso de corresponder la recompensa,
                    se devuelve el stake + la reward.
        * @notice  Dentro del segundo bloque solo devolvemos el stake inicial, como penalizacion 
                    no se devuelve ninguna recompensa.
    */

    function unStake() external {
        bool rewardControl = rewardCalculated(msg.sender);
        if (rewardControl) {
            require(contractBalance > StakeTokensUsers[msg.sender].tokenReward, ContractNotBalance() );
            totalTokensReward = StakeTokensUsers[msg.sender].amountTokenStaked + StakeTokensUsers[msg.sender].tokenReward;
            contractBalance = contractBalance - StakeTokensUsers[msg.sender].tokenReward;
            StakeTokensUsers[msg.sender].amountTokenStaked = 0;
            emit unStakeSuccess("UnStake amount plus rewards", totalTokensReward);
        } else {
            totalTokensReward = StakeTokensUsers[msg.sender].amountTokenStaked;
            StakeTokensUsers[msg.sender].amountTokenStaked = 0;
            emit NotRewardForTimestamp("UnstakeWithoutReward", totalTokensReward );
        }

        delete StakeTokensUsers[msg.sender];
    }


    /**
        * @notice  claimReward
        * @notice  Funcion que retira las rewards del user, sin sacar el los tokens stakeados,
                    dentro de la funcion se consume "rewardCalculated".
        * @notice  Lo mismo que en "unStake" el primer bloque maneja el caso de exito del stake, 
                    y el segundo solo devuelve un evento que no le corresponde rewards.
    */

    function claimReward() external {
        bool rewardControl = rewardCalculated(msg.sender);
        if (rewardControl) {
            totalTokensWithdraw = StakeTokensUsers[msg.sender].tokenReward;
            contractBalance = contractBalance - totalTokensWithdraw;
            emit SuccessClaimReward("SuccessClaimReward", totalTokensWithdraw);
        } else {
            emit NotWithdrawAvailable("NotWithdrawAvailable");
        }
    }



    /**
        * @notice ownerDeposit
        * @notice Funcion que deposita tokens al contrato (ficticios, ya que hardcodeamos los tokens con uint's)
                    que serviran para pagar las recompensas al user que haga stake. Only owner.
    */

    function ownerDeposit(uint256 _amount) external OnlyOwner {
        contractBalance += _amount;
        emit UpdateBalanceContract("Se actualizado el balance del contrato",contractBalance);
    }



    /**
        * @notice getBalance()
        * @notice Funcion para obtener el balance del contrato. Only owner.
    */

    function getBalance() external view OnlyOwner returns (uint256) {
        return contractBalance;
    }
}