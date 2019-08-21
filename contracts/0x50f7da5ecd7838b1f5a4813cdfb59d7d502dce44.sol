pragma solidity ^0.4.6;

contract DesafioStone {

  function DesafioStone() {}

  function o_aprendiz(uint a) constant returns (uint) {
    return a == 42 ? 1 : 0;
  }
  
  function o_algoritmo(uint a) constant returns (uint) {
    uint s = 0;
    for (uint i = 0; i < 21; ++i)
      s += i;
    return a == s / 5 ? 1 : 0;
  }

  function a_incognita(uint x) constant returns (uint) {
    return x*x*x + 3*x*x + 3*x + 7 == 2395346478 ? 1 : 0;
  }

  function a_empresa(bytes5 nome) constant returns (uint) {
    return sha3(nome) == 0x7cdf2c59fd49fab5ebabf1630c3a1f4d5c22c0aaa3651ca37dd688a69b33f3aa ? 1 : 0;
  }

  function o_desafiante(bytes14 nome) constant returns (uint) {
    return sha3(nome) == 0x71c6223d42fee2811e6f2ccfbb7bc5d1c57d47a97f9cbb8b2aedd67c312dc367 ? 1 : 0;
  }

  function a_palavra(bytes5 palavra) constant returns (uint) {
    return sha3(palavra) == 0x2e4588766bcfa3508dfb56a344fd7b1c3eca4954b2b8b795ab02209396528367 ? 2 : 0;
  }

  function o_velho_problema(uint a, uint b) constant returns (uint) {
    return a * b == 239811736052687 ? 2 : 0;
  }

  function o_novo_problema(uint x) constant returns (uint) {
    return 3 ** x == 0x5dd085b1f9816a47e96bf6f50b6717456ce772886c3e6686e020a456dc1a3623 ? 2 : 0;
  }

  function o_minerador(uint a) constant returns (uint) {
    bytes32 hash = sha3(a);
    for (uint i = 0; i < 32; ++i)
      if (hash[i] != 0)
        break;
    return i;
  }

  function o_automata(uint inicio) constant returns (uint) {
    uint[ 8] memory r = [uint(0),1,0,1,1,0,1,0];
    uint[16] memory x = [uint(0),1,1,0,0,1,1,0,0,1,1,0,0,1,1,0];
    uint[16] memory y = [uint(0),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];

    for (uint k = 0; k < 16; ++k)
      x[k] = inicio / (2 ** k) % 2;

    for (uint t = 0; t < 8; ++t) {
      for (uint p = 0; p < 16; ++p)
        y[p] = r[(p == 0 ? 0 : x[p-1]) + x[p] * 2 + (p == 15 ? 0 : x[p+1]) * 4];
      for (uint q = 0; q < 16; ++q)
        x[q] = y[q];
    }

    uint s = 0;
    for (uint i = 0; i < 16; ++i)
      s += x[i];

    return s <= 9 ? 0 : s <= 13 ? 1 : s <= 15 ? 4 : 8;
  }

  function o_labirinto(uint acoes) constant returns (uint) {
    uint map = 0xfff8800882288008c048fdf8e038e838e138fdf8f9f8fbf8fff8000000000000;
    uint x = 6;
    uint y = 11;

    for (uint i = 0; i < 64; ++i) {
      uint acao = acoes / (2 ** (256 - (i+1)*4)) % 0x10;

      if (acao == 0) y -= 1;
      if (acao == 1) x += 1;
      if (acao == 2) y += 1;
      if (acao == 3) x -= 1;

      uint index = 2 ** (255 - (y * 16 + x));

      if (map / index % 2 == 1)
        break;

      map = map + index;
    }

    return i / 8;
  }

  function o_deus(bytes32 a, bytes32 b) constant returns (uint) {
    return a != b && sha3(a) == sha3(b) ? 999999999 : 0;
  }

  function responder
    ( uint a
    , uint b
    , uint c
    , bytes5 d
    , bytes14 e
    , bytes5 f
    , uint g
    , uint h
    , uint i
    , uint j
    , uint k
    , uint l
    ) {
    uint pontos = 0;
    pontos += o_aprendiz(a);
    pontos += o_algoritmo(b);
    pontos += a_incognita(c);
    pontos += a_empresa(d);
    pontos += o_desafiante(e);
    pontos += a_palavra(f);
    pontos += o_velho_problema(g, h);
    pontos += o_novo_problema(i);
    pontos += o_minerador(j);
    pontos += o_automata(k);
    pontos += o_labirinto(l);
    address desafiado = 0xD12A749b6585Cb7605Aeb89455CD33aAeda1EbDB;
    if (pontos >= 20)
      if (desafiado.send(this.balance))
        return;
  }

  function() payable {}

}