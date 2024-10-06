// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// Smart Contract para crear un sistema de votación
contract Voting {
    //owner-----owner----
    // Dirección del admin
    address public owner;
    // Modificador para permitir solo al dueño ejecutar ciertas funciones
    modifier onlyOwner() {
        require(msg.sender == owner, "Solo el admin puede utilizar esta funcion");
        _;
    }
    //owner----owner----

    // Mapping para comprobar si un votante ya está registrado
    mapping(address => bool) public voters;

    // Estructura de la elección
    struct Eleccion {
        uint256 id;
        string name;
        uint16 votes;
    }

    // Estructura de la campaña de votación
    struct Ballot {
        uint256 id;
        string name;
        Eleccion[] elecciones; // Array de la estructura Elección
        uint end;
    }

    // Mapping de las campañas de votación
    mapping(uint => Ballot) public ballots;

    // Variable para incrementar las campañas
    uint nextBallotId;

    // Mapping para verificar si un votante ya ha votado en una campaña específica
    mapping(address => mapping(uint => bool)) public votes;

    // Constructor del contrato
    constructor() {
        owner = msg.sender;
    }

    // Función para añadir votantes
    function addVoters(address[] calldata _voters) external onlyOwner {
        for (uint i = 0; i < _voters.length; i++) {
            voters[_voters[i]] = true;
        }
    }

    // Función para crear una campaña de votación
    function createBallot(string memory name, string[] memory elecciones, uint offset) public onlyOwner {
        ballots[nextBallotId].id = nextBallotId;
        ballots[nextBallotId].name = name; // Guardando el name como string
        ballots[nextBallotId].end = block.timestamp + offset;

        for (uint i = 0; i < elecciones.length; i++) {
            ballots[nextBallotId].elecciones.push(Eleccion(uint256(i), elecciones[i], 0));  // Elecciones en string
        }

        nextBallotId++;
    }

    // Función para votar
    function vote(uint ballotId, uint eleccionId) external {
        require(voters[msg.sender] == true, "Solo los votantes pueden votar");
        require(votes[msg.sender][ballotId] == false, "Solo se puede votar una vez");
        require(block.timestamp < ballots[ballotId].end, "Las votaciones han finalizado");

        votes[msg.sender][ballotId] = true;
        ballots[ballotId].elecciones[eleccionId].votes++;
    }

    // Función para comprobar el resultado
    function result(uint ballotId) view external returns (Eleccion[] memory) {
        require(block.timestamp > ballots[ballotId].end, "Las votaciones todavia no han finalizado");
        return ballots[ballotId].elecciones;
    }
}
