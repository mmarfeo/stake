// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/* import "forge-std/Test.sol"; */
import "../src/Test.sol";
import "../src/staking.sol";


contract StakeSystemTest is Test {
    StakeSystem stake1;

    function setUp() public {
        uint256 initialBalance = 1000; // Balance inicial deseado para el contrato
        stake1 = new StakeSystem(initialBalance);
    }

    function testConstructorInitialization() public {
        // Verifica que el propietario se haya configurado correctamente
        assertEq(stake1.owner(), address(this), "El owner no es correcto");
        
        // Verifica que el balance inicial del contrato sea el correcto
        assertEq(stake1.contractBalance(), 1000, "El balance inicial no es correcto");

        // Verifica los valores de tiempo configurados en el constructor
        assertEq(stake1.oneYearStakeTimeStamp(), 60, unicode"El tiempo de stake de 1 año no es correcto");
        assertEq(stake1.twoYearStakeTimeStamp(), 120, unicode"El tiempo de stake de 2 años no es correcto");
        assertEq(stake1.threeYearStakeTimeStamp(), 180, unicode"El tiempo de stake de 3 años no es correcto");

        // Verifica las recompensas configuradas en el constructor
        assertEq(stake1.rewardForOneYear(), 25, unicode"La recompensa de 1 año no es correcta");
        assertEq(stake1.rewardForTwoYear(), 50, unicode"La recompensa de 2 años no es correcta");
        assertEq(stake1.rewardForThreeYear(), 75, unicode"La recompensa de 3 años no es correcta");
    }

    function testParseNumberToSeconds() public {
        // Prueba parseNumberToSeconds para cada entrada válida
        assertEq(stake1.parseNumberToSeconds(1), 60, unicode"El tiempo de 1 año no es correcto");
        assertEq(stake1.parseNumberToSeconds(2), 120, unicode"El tiempo de 2 años no es correcto");
        assertEq(stake1.parseNumberToSeconds(3), 180, unicode"El tiempo de 3 años no es correcto");

        // Prueba la respuesta ante un valor inválido
        vm.expectRevert("Invalid input");
        stake1.parseNumberToSeconds(4);
    }
}