# ArkZ Games — v260912

**Primeira versão pública** do **ArkZ Games**, um plugin (Application Bundle) para o
Autodesk AutoCAD com uma coleção de **12 jogos clássicos** escritos em **AutoLISP + DCL**.

## 🎮 Jogos incluídos

| # | Jogo | Comando |
|:-:|:-----|:--------|
| 1 | Conecte-4 | `Connect4` |
| 2 | Damas 8×8 | `Damas_8x8` |
| 3 | Campo Minado 8×8 | `Minesweeper_8x8` |
| 4 | Quebra-cabeça 3×3 (8-puzzle) | `Puzzle_3x3` |
| 5 | Quebra-cabeça 4×4 (15-puzzle) | `Puzzle_4x4` |
| 6 | Jogo 2048 | `Game2048` |
| 7 | Sudoku | `Sudoku` |
| 8 | Batalha Naval 8×8 | `SeaBattle_8x8` |
| 9 | Jogo da Velha 3×3 | `TicTacToe_3x3` |
| 10 | Jogo da Velha 4×4 | `TicTacToe_4x4` |
| 11 | Torre de Hanói | `Hanoi` |
| 12 | Wordle | `Wordle` |

## 📦 Instalação

1. Baixe o arquivo **`ArkZGames_v_260912_Setup.exe`** abaixo (seção *Assets*).
2. Execute o instalador (requer privilégios de administrador).
3. Abra o AutoCAD — a aba **Ark-Z Games** aparecerá automaticamente na faixa de opções.

> Instalação manual: copie o conteúdo de `Fonts/` para a pasta
> `%APPDATA%\Autodesk\ApplicationPlugins\ArkZGames.bundle` e reinicie o AutoCAD.

## ✅ Requisitos

- **AutoCAD 2013 a 2026** (Windows 32/64 bits) — testado em versões R19.0 a R26.0.
- Permissão de administrador para instalar o bundle em `Program Files`.

## 🚀 Como jogar

Acesse a aba **Ark-Z Games** na faixa de opções **ou** digite o comando do jogo
diretamente na linha de comando (ex.: `Wordle`).

## 🛠️ Novidades desta versão

- Estrutura inicial do bundle `ArkZGames.bundle` (`PackageContents.xml`) com carga automática.
- Aba **Ark-Z Games** na faixa de opções (`ArkZGames.cuix`) com todos os comandos.
- Interface totalmente em **português (pt-BR)**, com diálogos DCL e imagens em slides (`.slb`).
- Oponente controlado por computador em Conecte-4, Damas, Batalha Naval e Jogo da Velha.
- Instalador em **Inno Setup** com desinstalação que remove arquivos residuais `.cuix` / `.mnr`.

---

Consulte o [README.MD](README.MD) para a documentação completa e capturas de tela de cada jogo.

*AutoCAD® e Autodesk® são marcas registradas da Autodesk, Inc. Este projeto é um trabalho
independente e não é afiliado, associado, autorizado ou endossado pela Autodesk.*
