;; ====================================================================
;; SEA BATTLE 8x8 - BATALHA NAVAL PARA AUTOCAD
;; ====================================================================
;; DESENVOLVIDO POR: EZEQUIEL M REZENDE
;; COM A AJUDA DO GOOGLE GEMINI - DEEPSEEK
;; VERSÃO: 1.0 (FINAL)
;; DATA: 2025/12/12
;;
;; DESCRIÇÃO: Jogo completo de Batalha Naval com interface gráfica DCL
;;            e Inteligência Artificial avançada. Tabuleiro 8x8 com
;;            diferentes tipos de navios representados visualmente.
;; ====================================================================

;; ====================================================================
;; SEÇÃO 1: VARIÁVEIS GLOBAIS DO JOGO
;; ====================================================================

;; --------------------------------------------------------------------
;; VARIÁVEL: SB_dcl_id
;; DESCRIÇÃO: Identificador do diálogo DCL carregado
;; TIPO: Integer ou nil
;; --------------------------------------------------------------------
(setq SB_dcl_id nil)

;; --------------------------------------------------------------------
;; VARIÁVEL: SB_board_size
;; DESCRIÇÃO: Tamanho do tabuleiro (8x8)
;; TIPO: Integer
;; VALOR: 8
;; --------------------------------------------------------------------
(setq SB_board_size 8)

;; --------------------------------------------------------------------
;; VARIÁVEL: SB_board_player
;; DESCRIÇÃO: Matriz 8x8 representando o tabuleiro do jogador
;;            Contém navios do jogador e tiros do computador
;; TIPO: Lista de listas
;; FORMATO: ((linha0) (linha1) ... (linha7))
;; --------------------------------------------------------------------
(setq SB_board_player nil)

;; --------------------------------------------------------------------
;; VARIÁVEL: SB_board_computer
;; DESCRIÇÃO: Matriz 8x8 representando o tabuleiro do computador
;;            Contém navios do computador e tiros do jogador
;; TIPO: Lista de listas
;; --------------------------------------------------------------------
(setq SB_board_computer nil)

;; --------------------------------------------------------------------
;; VARIÁVEL: SB_player_turn
;; DESCRIÇÃO: Indica de quem é o turno atual
;; TIPO: Symbol
;; VALORES: 'JOGADOR ou 'COMPUTADOR
;; --------------------------------------------------------------------
(setq SB_player_turn 'JOGADOR)

;; --------------------------------------------------------------------
;; VARIÁVEL: SB_selected_target
;; DESCRIÇÃO: Alvo selecionado pelo jogador para atirar
;; TIPO: List (row col) ou nil
;; --------------------------------------------------------------------
(setq SB_selected_target nil)

;; --------------------------------------------------------------------
;; VARIÁVEL: SB_game_state
;; DESCRIÇÃO: Estado atual do jogo
;; TIPO: Symbol
;; VALORES: 'POSITIONING, 'PLAYING, 'ENDED
;; --------------------------------------------------------------------
(setq SB_game_state 'POSITIONING)

;; --------------------------------------------------------------------
;; VARIÁVEL: *SB_game_history*
;; DESCRIÇÃO: Histórico de todos os movimentos do jogo
;; TIPO: List
;; FORMATO: ((jogador row col resultado) ...)
;; --------------------------------------------------------------------
(setq *SB_game_history* nil)

;; --------------------------------------------------------------------
;; VARIÁVEL: *SB_save_file*
;; DESCRIÇÃO: Nome do arquivo para salvar estado do jogo
;; TIPO: String
;; --------------------------------------------------------------------
(setq *SB_save_file* "SeaBattle_save.txt")

;; --------------------------------------------------------------------
;; VARIÁVEL: *SB_notation_file*
;; DESCRIÇÃO: Nome do arquivo para salvar notação da partida
;; TIPO: String
;; --------------------------------------------------------------------
(setq *SB_notation_file* "SeaBattle_notation.txt")

;; --------------------------------------------------------------------
;; VARIÁVEL: *SB_ship_types*
;; DESCRIÇÃO: Configuração dos tipos e quantidades de navios
;; TIPO: Lista de pares (tamanho . quantidade)
;; FORMATO: ((5 . 1) (4 . 1) (3 . 2) (2 . 3) (1 . 4))
;; SIGNIFICADO:
;;   - 5 células: Porta-aviões (1 unidade)
;;   - 4 células: Navio de guerra (1 unidade)
;;   - 3 células: Cruzador (2 unidades)
;;   - 2 células: Destroyer (3 unidades)
;;   - 1 célula: Submarino (4 unidades)
;; --------------------------------------------------------------------
(setq *SB_ship_types* '((5 . 1) (4 . 1) (3 . 2) (2 . 3) (1 . 4)))

;; --------------------------------------------------------------------
;; VARIÁVEL: SB_ships_player
;; DESCRIÇÃO: Lista de navios do jogador com contagem de acertos
;; TIPO: List
;; FORMATO: ((tipo hits_atuais hits_max) ...)
;; --------------------------------------------------------------------
(setq SB_ships_player nil)

;; --------------------------------------------------------------------
;; VARIÁVEL: SB_ships_computer
;; DESCRIÇÃO: Lista de navios do computador com contagem de acertos
;; TIPO: List
;; --------------------------------------------------------------------
(setq SB_ships_computer nil)

;; ====================================================================
;; SEÇÃO 2: VARIÁVEIS DA INTELIGÊNCIA ARTIFICIAL (IA)
;; ====================================================================

;; --------------------------------------------------------------------
;; VARIÁVEL: *SB_seed*
;; DESCRIÇÃO: Semente para o gerador de números aleatórios
;; TIPO: Integer
;; NOTA: Inicializada automaticamente por SB_randnum()
;; --------------------------------------------------------------------
(setq *SB_seed* nil)

;; --------------------------------------------------------------------
;; VARIÁVEL: *SB_ai_targets_hit*
;; DESCRIÇÃO: Histórico de coordenadas onde a IA acertou navios
;; TIPO: List de listas
;; FORMATO: ((row1 col1) (row2 col2) ...)
;; USO: Para estratégia de destruição (targeting mode)
;; --------------------------------------------------------------------
(setq *SB_ai_targets_hit* nil)

;; --------------------------------------------------------------------
;; VARIÁVEL: *SB_ai_targets_miss*
;; DESCRIÇÃO: Histórico de coordenadas onde a IA errou
;; TIPO: List de listas
;; --------------------------------------------------------------------
(setq *SB_ai_targets_miss* nil)

;; --------------------------------------------------------------------
;; VARIÁVEL: *SB_ai_hunting_pattern*
;; DESCRIÇÃO: Padrão de busca em grade (chequerboard) otimizado
;; TIPO: List de coordenadas
;; FORMATO: ((row1 col1) (row2 col2) ...)
;; GERAÇÃO: Função SB_generate_hunting_pattern()
;; --------------------------------------------------------------------
(setq *SB_ai_hunting_pattern* nil)

;; --------------------------------------------------------------------
;; VARIÁVEL: *SB_ai_ship_direction*
;; DESCRIÇÃO: Direção detectada do navio sendo atacado
;; TIPO: Symbol ou nil
;; VALORES: 'HORIZONTAL, 'VERTICAL, nil
;; DETECÇÃO: Após pelo menos 2 acertos no mesmo navio
;; --------------------------------------------------------------------
(setq *SB_ai_ship_direction* nil)

;; --------------------------------------------------------------------
;; VARIÁVEL: *SB_ai_last_hits*
;; DESCRIÇÃO: Últimos acertos para análise de direção
;; TIPO: List de coordenadas
;; --------------------------------------------------------------------
(setq *SB_ai_last_hits* nil)

;; --------------------------------------------------------------------
;; VARIÁVEL: *SB_ai_probability_grid*
;; DESCRIÇÃO: Grade 8x8 com probabilidades de haver navio em cada célula
;; TIPO: Matriz 8x8 de inteiros
;; CÁLCULO: Função SB_calculate_probability_grid()
;; --------------------------------------------------------------------
(setq *SB_ai_probability_grid* nil)

;; --------------------------------------------------------------------
;; VARIÁVEL: *SB_ai_ships_remaining*
;; DESCRIÇÃO: Contagem de navios do jogador ainda não afundados
;; TIPO: Lista de pares (tamanho . quantidade)
;; INICIAL: ((5 . 1) (4 . 1) (3 . 2) (2 . 3) (1 . 4))
;; ATUALIZAÇÃO: Função SB_update_remaining_ships()
;; --------------------------------------------------------------------
(setq *SB_ai_ships_remaining* '((5 . 1) (4 . 1) (3 . 2) (2 . 3) (1 . 4)))

;; --------------------------------------------------------------------
;; VARIÁVEL: *SB_game_mode*
;; DESCRIÇÃO: Modo de jogo selecionado
;; TIPO: Symbol
;; VALORES: 'CLASSIC, 'FAST, 'CHALLENGE
;; INICIAL: 'CLASSIC (padrão)
;; --------------------------------------------------------------------
(setq *SB_game_mode* 'CLASSIC)

;; --------------------------------------------------------------------
;; VARIÁVEL: *SB_mode_descriptions*
;; DESCRIÇÃO: Descrições dos modos para exibição no DCL
;; TIPO: Lista de strings
;; --------------------------------------------------------------------
(setq *SB_mode_descriptions*
  '(
    "Clássico: 1 Porta-aviões, 1 Navio de guerra, 2 Cruzadores, 1 Destroyer, 1 Submarino. (Total: 6 navios)"
    "Rápido: 1 Navio de guerra, 1 Cruzador, 2 Destroyers, 2 Submarinos. (Total: 6 navios)"
    "Desafiador: 1 Porta-aviões, 1 Navio de guerra, 2 Cruzadores, 3 Destroyers 4 Submarinos. (Total: 11 navios)"
  )
)

;; ====================================================================
;; SEÇÃO 3: FUNÇÕES AUXILIARES BÁSICAS
;; ====================================================================

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_drop
;; DESCRIÇÃO: Remove os primeiros n elementos de uma lista
;; PARÂMETROS:
;;   - n: Número de elementos a remover (Integer)
;;   - lst: Lista original (List)
;; RETORNO: Lista resultante (List)
;; EXEMPLO: (SB_drop 2 '(a b c d)) retorna '(c d)
;; --------------------------------------------------------------------
(defun SB_drop (n lst)
  (if (<= n 0) 
      lst 
      (if (cdr lst) 
          (SB_drop (1- n) (cdr lst)) 
          nil
      )
  )
)

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_take
;; DESCRIÇÃO: Retorna os primeiros n elementos de uma lista
;; PARÂMETROS:
;;   - n: Número de elementos a retornar (Integer)
;;   - lst: Lista original (List)
;; RETORNO: Lista com n elementos (List)
;; EXEMPLO: (SB_take 2 '(a b c d)) retorna '(a b)
;; --------------------------------------------------------------------
(defun SB_take (n lst)
  (if (or (<= n 0) (null lst)) 
      nil 
      (cons (car lst) (SB_take (1- n) (cdr lst)))
  )
)

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_update_cell
;; DESCRIÇÃO: Atualiza o valor de uma célula específica no tabuleiro
;; PARÂMETROS:
;;   - board: Tabuleiro a ser modificado (List)
;;   - row: Índice da linha (0-7) (Integer)
;;   - col: Índice da coluna (0-7) (Integer)
;;   - value: Novo valor para a célula (Any)
;; RETORNO: Tabuleiro modificado (List)
;; ALGORITMO:
;;   1. Mantém as linhas antes da linha alvo (SB_take row)
;;   2. Modifica a linha alvo: mantém colunas antes, insere valor, mantém depois
;;   3. Adiciona as linhas após a linha alvo (SB_drop (1+ row))
;; --------------------------------------------------------------------
(defun SB_update_cell (board row col value)
  (append 
    (SB_take row board) 
    (list 
      (append 
        (SB_take col (nth row board)) 
        (list value) 
        (SB_drop (1+ col) (nth row board))
      )
    ) 
    (SB_drop (1+ row) board)
  )
)

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_get_cell
;; DESCRIÇÃO: Obtém o valor de uma célula específica do tabuleiro
;; PARÂMETROS:
;;   - board: Tabuleiro a ser consultado (List)
;;   - row: Índice da linha (0-7) (Integer)
;;   - col: Índice da coluna (0-7) (Integer)
;; RETORNO: Valor da célula ou nil se coordenadas inválidas
;; VALORES POSSÍVEIS:
;;   - nil: Célula vazia/água
;;   - 'HIT: Tiro acertou navio
;;   - 'MISS: Tiro na água
;;   - 'CARRIER: Porta-aviões
;;   - 'BATTLESHIP: Navio de guerra
;;   - 'CRUISER: Cruzador
;;   - 'DESTROYER: Destroyer
;;   - 'SUBMARINE: Submarino
;; --------------------------------------------------------------------
(defun SB_get_cell (board row col / piece)
  (if (and (>= row 0) 
           (< row SB_board_size) 
           (>= col 0) 
           (< col SB_board_size))
      (setq piece (nth col (nth row board)))
      (setq piece nil)
  )
  piece
)

;; ====================================================================
;; SEÇÃO 4: GERADOR DE NÚMEROS ALEATÓRIOS
;; ====================================================================

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_randnum
;; DESCRIÇÃO: Gerador congruente linear (LCG) de números pseudo-aleatórios
;; ALGORITMO: X??1 = (a × X? + c) mod m
;; PARÂMETROS FIXOS:
;;   - modulus (m): 65536
;;   - multiplier (a): 25173
;;   - increment (c): 13849
;; RETORNO: Número float entre 0.0 e 1.0
;; INICIALIZAÇÃO: Automática se *SB_seed* for nil ou não-inteiro
;; NOTA: Usa variável global '*SB_seed*' como estado interno
;; --------------------------------------------------------------------
(defun SB_randnum (/ modulus multiplier increment random_float)
  ;; Inicializa a semente se for nula ou não inteira
  (cond
    ((null *SB_seed*)
      (setq *SB_seed* (fix (getvar "DATE")))
      (princ (strcat "\n[INIT] Semente inicializada para: " (vl-princ-to-string *SB_seed*)))
    )
    ((/= (type *SB_seed*) 'INT)
      (setq *SB_seed* (fix *SB_seed*))
      (princ (strcat "\n[CORRECAO] Semente convertida para inteiro: " (vl-princ-to-string *SB_seed*)))
    )
  )
  
  ;; Parâmetros do LCG (valores comuns para geradores de 16 bits)
  (setq modulus    65536
        multiplier 25173
        increment  13849
  )
  
  ;; Aplica a fórmula do LCG
  (setq *SB_seed* (rem (+ (* multiplier *SB_seed*) increment) modulus))
  
  ;; Normaliza para intervalo [0.0, 1.0]
  (setq random_float (/ (float *SB_seed*) (float modulus)))
  
  random_float
)

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_get_random_coord
;; DESCRIÇÃO: Gera coordenada aleatória entre 0 e 7 com fallback seguro
;; PARÂMETROS: Nenhum
;; RETORNO: Número inteiro entre 0 e 7
;; FALLBACK: Usa getvar "DATE" se SB_randnum falhar
;; USO: Para posicionamento inicial de navios
;; --------------------------------------------------------------------
(defun SB_get_random_coord (/ random_val)
  (setq random_val (SB_randnum))
  
  (if (null random_val)
    (progn
      (princ "\nAVISO: Falha na função SB_randnum (NIL). Usando CDATE como fallback seguro.")
      (rem (fix (getvar "DATE")) 8)
    )
    (fix (* random_val 8))
  )
)

;; ====================================================================
;; SEÇÃO 5: FUNÇÕES AUXILIARES DA IA AVANÇADA
;; ====================================================================

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_generate_hunting_pattern
;; DESCRIÇÃO: Gera padrão de busca em grade (chequerboard) otimizado
;; ALGORITMO:
;;   1. Para cada linha (0-7):
;;      - Linhas pares: começa na coluna 0
;;      - Linhas ímpares: começa na coluna 1
;;   2. Adiciona células a cada 2 colunas (padrão de xadrez)
;;   3. Embaralha o padrão para evitar previsibilidade
;; PARÂMETROS: Nenhum
;; RETORNO: Lista de coordenadas (row col) embaralhadas
;; EFICIÊNCIA: Cobre 50% do tabuleiro (32 células de 64)
;; --------------------------------------------------------------------
(defun SB_generate_hunting_pattern (/ pattern row col start)
  (setq pattern '())
  (setq row 0)
  (while (< row 8)
    ;; Alterna início das colunas para padrão de xadrez
    (setq start (if (= (rem row 2) 0) 0 1))
    (setq col start)
    (while (< col 8)
      (setq pattern (cons (list row col) pattern))
      (setq col (+ col 2))
    )
    (setq row (1+ row))
  )
  ;; Embaralha o padrão
  (SB_shuffle_list pattern)
)

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_shuffle_list
;; DESCRIÇÃO: Embaralha uma lista usando algoritmo Fisher-Yates
;; PARÂMETROS:
;;   - lst: Lista a ser embaralhada (List)
;; RETORNO: Lista embaralhada (List)
;; COMPLEXIDADE: O(n) onde n é o tamanho da lista
;; --------------------------------------------------------------------
(defun SB_shuffle_list (lst / len i j temp result)
  (setq result (vl-list* lst))
  (setq len (length lst))
  (setq i 0)
  (while (< i len)
    (setq j (fix (* (SB_randnum) len)))
    (setq temp (nth i result))
    (setq result (SB_update_nth result i (nth j result)))
    (setq result (SB_update_nth result j temp))
    (setq i (1+ i))
  )
  result
)

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_update_nth
;; DESCRIÇÃO: Atualiza o elemento na posição n de uma lista
;; PARÂMETROS:
;;   - lst: Lista original (List)
;;   - n: Posição a atualizar (0-indexed) (Integer)
;;   - val: Novo valor (Any)
;; RETORNO: Lista modificada (List)
;; RECURSÃO: Implementação recursiva
;; --------------------------------------------------------------------
(defun SB_update_nth (lst n val / head tail)
  (if (= n 0)
    (cons val (cdr lst))
    (cons (car lst) (SB_update_nth (cdr lst) (1- n) val))
  )
)

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_detect_ship_direction
;; DESCRIÇÃO: Detecta a direção de um navio baseado em acertos consecutivos
;; PARÂMETROS:
;;   - hits: Lista de coordenadas onde o navio foi atingido (List)
;; RETORNO: 'HORIZONTAL, 'VERTICAL, ou nil
;; LÓGICA:
;;   - Precisão de pelo menos 2 acertos
;;   - Se mesma linha: horizontal
;;   - Se mesma coluna: vertical
;;   - Caso contrário: direção indeterminada
;; --------------------------------------------------------------------
(defun SB_detect_ship_direction (hits)
  (cond
    ((< (length hits) 2) nil)
    ((= (caar hits) (caadr hits)) 'HORIZONTAL)
    ((= (cadar hits) (cadadr hits)) 'VERTICAL)
    (T nil)
  )
)

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_calculate_probability_grid
;; DESCRIÇÃO: Calcula grade de probabilidade de haver navio em cada célula
;; ALGORITMO:
;;   1. Para cada célula não atingida:
;;      a. Para cada tipo de navio restante:
;;         i. Verifica todas as posições horizontais possíveis
;;         ii. Verifica todas as posições verticais possíveis
;;         iii. Incrementa contador para cada posição válida
;;   2. Células já atingidas recebem probabilidade 0
;; PARÂMETROS: Nenhum
;; RETORNO: Matriz 8x8 com valores de probabilidade (List)
;; COMPLEXIDADE: O(n³) - aceitável para 8x8
;; --------------------------------------------------------------------
(defun SB_calculate_probability_grid (/ grid row col ship_type prob total_prob)
  (setq grid (SB_initialize_board 0))
  
  (setq row 0)
  (while (< row 8)
    (setq col 0)
    (while (< col 8)
      (setq cell_content (SB_get_cell SB_board_player row col))
      (if (not (member cell_content '(HIT MISS)))
        (progn
          (setq total_prob 0)
          
          (foreach ship_tuple *SB_ai_ships_remaining*
            (setq ship_size (car ship_tuple))
            (setq ship_count (cdr ship_tuple))
            
            (if (> ship_count 0)
              (progn
                ;; Verifica posições horizontais possíveis
                (setq col_start (max 0 (- col ship_size -1)))
                (setq col_end (min col (- 8 ship_size)))
                
                (setq c col_start)
                (while (<= c col_end)
                  (setq valid T)
                  (setq k 0)
                  (while (and valid (< k ship_size))
                    (setq test_cell (SB_get_cell SB_board_player row (+ c k)))
                    (if (member test_cell '(HIT MISS))
                      (setq valid nil)
                    )
                    (setq k (1+ k))
                  )
                  
                  (if valid (setq total_prob (+ total_prob 1)))
                  (setq c (1+ c))
                )
                
                ;; Verifica posições verticais possíveis
                (setq row_start (max 0 (- row ship_size -1)))
                (setq row_end (min row (- 8 ship_size)))
                
                (setq r row_start)
                (while (<= r row_end)
                  (setq valid T)
                  (setq k 0)
                  (while (and valid (< k ship_size))
                    (setq test_cell (SB_get_cell SB_board_player (+ r k) col))
                    (if (member test_cell '(HIT MISS))
                      (setq valid nil)
                    )
                    (setq k (1+ k))
                  )
                  
                  (if valid (setq total_prob (+ total_prob 1)))
                  (setq r (1+ r))
                )
              )
            )
          )
          
          (setq grid (SB_update_cell grid row col total_prob))
        )
        (setq grid (SB_update_cell grid row col 0))
      )
      (setq col (1+ col))
    )
    (setq row (1+ row))
  )
  
  grid
)

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_find_highest_probability_cell
;; DESCRIÇÃO: Encontra célula com maior valor de probabilidade
;; PARÂMETROS:
;;   - prob_grid: Grade de probabilidades (List)
;; RETORNO: Lista (row col) da célula com maior probabilidade ou nil
;; ALGORITMO: Busca linear em toda a grade
;; --------------------------------------------------------------------
(defun SB_find_highest_probability_cell (prob_grid / max_prob best_row best_col row col current_prob)
  (setq max_prob -1)
  (setq best_row nil)
  (setq best_col nil)
  
  (setq row 0)
  (while (< row 8)
    (setq col 0)
    (while (< col 8)
      (setq current_prob (SB_get_cell prob_grid row col))
      (if (> current_prob max_prob)
        (progn
          (setq max_prob current_prob)
          (setq best_row row)
          (setq best_col col)
        )
      )
      (setq col (1+ col))
    )
    (setq row (1+ row))
  )
  
  (if best_row (list best_row best_col) nil)
)

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_update_remaining_ships
;; DESCRIÇÃO: Atualiza contagem de navios restantes após afundamento
;; PARÂMETROS:
;;   - sunk_ship_type: Tipo do navio afundado (Symbol)
;; RETORNO: Nenhum (atualiza variável global *SB_ai_ships_remaining*)
;; LÓGICA:
;;   1. Determina tamanho do navio afundado
;;   2. Decrementa contagem correspondente
;;   3. Garante que contagem não fique negativa
;; --------------------------------------------------------------------
(defun SB_update_remaining_ships (sunk_ship_type)
  (if sunk_ship_type
    (progn
      (setq ship_size 
        (cond
          ((eq sunk_ship_type 'CARRIER) 5)
          ((eq sunk_ship_type 'BATTLESHIP) 4)
          ((eq sunk_ship_type 'CRUISER) 3)
          ((eq sunk_ship_type 'DESTROYER) 2)
          ((eq sunk_ship_type 'SUBMARINE) 1)
        )
      )
      
      (setq new_ships_remaining '())
      (foreach ship_tuple *SB_ai_ships_remaining*
        (if (= (car ship_tuple) ship_size)
          (setq new_ships_remaining (cons (cons ship_size (max 0 (1- (cdr ship_tuple)))) new_ships_remaining))
          (setq new_ships_remaining (cons ship_tuple new_ships_remaining))
        )
      )
      (setq *SB_ai_ships_remaining* (reverse new_ships_remaining))
      
      (princ (strcat "\n[IA] Navio tamanho " (itoa ship_size) " afundado. Restantes atualizados."))
    )
  )
)

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_get_valid_adjacent_targets
;; DESCRIÇÃO: Retorna células adjacentes válidas para ataque
;; PARÂMETROS:
;;   - row: Linha da célula central (Integer)
;;   - col: Coluna da célula central (Integer)
;;   - board_name: Símbolo do tabuleiro a verificar (Symbol)
;; RETORNO: Lista de coordenadas adjacentes válidas (List)
;; DIREÇÕES VERIFICADAS: Norte, Sul, Leste, Oeste
;; VALIDAÇÕES:
;;   1. Limites do tabuleiro (0-7)
;;   2. Célula não foi anteriormente atingida (HIT/MISS)
;; --------------------------------------------------------------------
(defun SB_get_valid_adjacent_targets (row col board_name / adj_list r c board_data valid_targets cell_val)
  (setq adj_list (list (list (1- row) col)   ; Norte
                       (list (1+ row) col)   ; Sul
                       (list row (1- col))   ; Oeste
                       (list row (1+ col))   ; Leste
                ))
  
  (setq board_data (eval board_name))
  (setq valid_targets nil)

  (foreach coord adj_list
    (setq r (car coord))
    (setq c (cadr coord))
    
    (if (and (>= r 0) (< r SB_board_size)
             (>= c 0) (< c SB_board_size))
      (progn
        (setq cell_val (SB_get_cell board_data r c))
        (if (not (member cell_val '(HIT MISS)))
          (setq valid_targets (cons (list r c) valid_targets))
        )
      )
    )
  )
  valid_targets
)
;; ====================================================================
;; FUNÇÕES PARA MANIPULAÇÃO DE MODOS
;; ====================================================================

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_get_ship_configuration
;; DESCRIÇÃO: Retorna configuração de navios baseada no modo selecionado
;; PARÂMETROS:
;;   - mode: Modo de jogo (Symbol)
;; RETORNO: Lista de pares (tamanho . quantidade)
;; MODOS:
;;   - CLASSIC: Configuração tradicional (6 navios, 17 células)
;;   - FAST: Jogo rápido (5 navios, 12 células)
;;   - CHALLENGE: Jogo desafiador (11 navios, 25 células)
;; --------------------------------------------------------------------
(defun SB_get_ship_configuration (mode)
  (cond
    ((eq mode 'FAST)
      '((4 . 1) (3 . 1) (2 . 2) (1 . 2))  ; 5 navios, 12 células
    )
    ((eq mode 'CLASSIC)
      '((5 . 1) (4 . 1) (3 . 2) (2 . 1) (1 . 1))  ; 6 navios, 17 células
    )
    ((eq mode 'CHALLENGE)
      '((5 . 1) (4 . 1) (3 . 2) (2 . 3) (1 . 4))  ; 11 navios, 25 células
    )
    (T  ; Fallback para clássico
      '((5 . 1) (4 . 1) (3 . 2) (2 . 1) (1 . 1))
    )
  )
)

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_update_mode_description
;; DESCRIÇÃO: Atualiza a descrição do modo no DCL
;; PARÂMETROS:
;;   - mode: Modo de jogo (Symbol)
;; RETORNO: Nenhum (atualiza tile do DCL)
;; --------------------------------------------------------------------
(defun SB_update_mode_description (mode)
  (set_tile "mode_desc"
    (cond
      ((eq mode 'FAST)
        "Rápido: 1 Navio de guerra, 1 Cruzador, 2 Destroyers, 2 Submarinos. (Total: 6 navios)"
      )
      ((eq mode 'CLASSIC)
         "Clássico: 1 Porta-aviões, 1 Navio de guerra, 2 Cruzadores, 1 Destroyer, 1 Submarino. (Total: 6 navios)"
      )
      ((eq mode 'CHALLENGE)
        "Desafiador: 1 Porta-aviões, 1 Navio de guerra, 2 Cruzadores, 3 Destroyers 4 Submarinos. (Total: 11 navios)"
      )
      (T "Modo não reconhecido")
    )
  )
)

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_setup_mode_controls
;; DESCRIÇÃO: Configura os action_tiles para os radio_buttons de modo
;; PARÂMETROS: Nenhum
;; RETORNO: Nenhum
;; --------------------------------------------------------------------
(defun SB_setup_mode_controls ()
  ;; Configura ações para radio buttons
  (action_tile "mode_classic" 
    "(setq *SB_game_mode* 'CLASSIC) (SB_update_mode_description 'CLASSIC)"
  )
  (action_tile "mode_fast" 
    "(setq *SB_game_mode* 'FAST) (SB_update_mode_description 'FAST)"
  )
  (action_tile "mode_challenge" 
    "(setq *SB_game_mode* 'CHALLENGE) (SB_update_mode_description 'CHALLENGE)"
  )
  
  ;; Configura estado inicial (Clássico selecionado)
  (set_tile "mode_classic" "1")
  (set_tile "mode_fast" "0")
  (set_tile "mode_challenge" "0")
  (SB_update_mode_description 'CLASSIC)
)

;; ====================================================================
;; SEÇÃO 6: FUNÇÕES DE INICIALIZAÇÃO E TABULEIRO
;; ====================================================================

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_initialize_board
;; DESCRIÇÃO: Cria um novo tabuleiro vazio com valor inicial especificado
;; PARÂMETROS:
;;   - initial_value: Valor para preencher todas as células (Any)
;; RETORNO: Matriz 8x8 (List de listas)
;; ALGORITMO: Dois loops aninhados (row, col)
;; --------------------------------------------------------------------
(defun SB_initialize_board (initial_value / new_board row col current_row)
  (setq new_board nil)
  (setq row 0)
  (while (< row SB_board_size)
    (setq current_row nil)
    (setq col 0)
    (while (< col SB_board_size)
      (setq current_row (append current_row (list initial_value)))
      (setq col (1+ col))
    )
    (setq new_board (append new_board (list current_row)))
    (setq row (1+ row))
  )
  new_board
)

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_ShowSld
;; DESCRIÇÃO: Exibe um slide em um tile DCL com cor de fundo especificada
;; PARÂMETROS:
;;   - tile: Nome/identificador do tile DCL (String)
;;   - slide: Nome do slide a ser exibido (String)
;;   - color: Cor de fundo (Integer - código AutoCAD)
;; RETORNO: Nenhum (efeito colateral no DCL)
;; FORMATO DO SLIDE: "SEABATTLE(nome_do_slide)"
;; --------------------------------------------------------------------
(defun SB_ShowSld (tile slide color / x y)
  (setq x (dimx_tile tile))
  (setq y (dimy_tile tile))
  (start_image tile)
  (fill_image 0 0 x y color)
  (slide_image 0 0 x y
    (strcat "SeaBattle_8x8" "(" slide ")")
  )
  (end_image)
  (princ)
)

;; ====================================================================
;; SEÇÃO 7: INICIALIZAÇÃO DO JOGO
;; ====================================================================

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_initialize_game_SeaBattle
;; DESCRIÇÃO: Inicializa todas as variáveis e componentes do jogo
;; FLUXO:
;;   1. Cria tabuleiros vazios
;;   2. Inicializa variáveis de estado
;;   3. Configura IA avançada
;;   4. Posiciona navios automaticamente
;;   5. Define estado inicial do jogo
;; RETORNO: Nenhum (efeito colateral nas variáveis globais)
;; --------------------------------------------------------------------
(defun SB_initialize_game_SeaBattle ()
  ;; 1. Cria tabuleiros
  (setq SB_board_player (SB_initialize_board nil))
  (setq SB_board_computer (SB_initialize_board nil))
  
  ;; 2. Inicializa variáveis de estado
  (setq SB_player_turn 'JOGADOR) 
  (setq SB_selected_target nil)
  (setq SB_game_state 'POSITIONING) 
  (setq *SB_game_history* nil) 
  
  ;; 3. Obtém configuração de navios baseada no modo selecionado
  (setq *SB_ship_types* (SB_get_ship_configuration *SB_game_mode*))
  
  ;; 4. Configura IA avançada (com navios restantes do modo atual)
  (setq *SB_ai_targets_hit* nil)
  (setq *SB_ai_targets_miss* nil)
  (setq *SB_ai_hunting_pattern* nil)
  (setq *SB_ai_ship_direction* nil)
  (setq *SB_ai_last_hits* nil)
  (setq *SB_ai_probability_grid* nil)
  (setq *SB_ai_ships_remaining* (SB_get_ship_configuration *SB_game_mode*))
  
  ;; 5. Inicializa gerador aleatório
  (if (and (boundp 'vl-random) (vl-random 1)) (vl-load-com))
  (if (and (boundp 'rand) (rand 1)) (setq *random_seed* (getvar "DATE")))
  
  ;; 6. Inicializa listas de navios
  (setq SB_ships_player '()) 
  (setq SB_ships_computer '()) 
  
  ;; 7. Posiciona navios automaticamente (com configuração do modo)
  (SB_position_ships 'SB_board_player 'PLAYER)
  (repeat 10 (SB_randnum)) ; Avança semente para diferentes tabuleiros
  (SB_position_ships 'SB_board_computer 'COMPUTER)
  
  ;; 8. Define estado do jogo
  (setq SB_game_state 'PLAYING)
  (set_tile "turn_status" 
    (strcat "JOGADOR (Seu Turno) - Modo: " 
            (cond
              ((eq *SB_game_mode* 'FAST) "RÁPIDO")
              ((eq *SB_game_mode* 'CLASSIC) "CLÁSSICO")
              ((eq *SB_game_mode* 'CHALLENGE) "DESAFIADOR")
              (T "PADRÃO")
            )
    )
  )
  (action_tile "turn_status" "") 
  
  ;; 9. Atualiza display
  (SB_update_board_display)
  
  ;; 10. Mensagem informativa
  (princ (strcat "\nTabuleiro inicializado. Modo: " 
                 (cond
                   ((eq *SB_game_mode* 'FAST) "RÁPIDO (5 navios)")
                   ((eq *SB_game_mode* 'CLASSIC) "CLÁSSICO (6 navios)")
                   ((eq *SB_game_mode* 'CHALLENGE) "DESAFIADOR (11 navios)")
                   (T "PADRÃO")
                 )
  ))
)

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_position_ships
;; DESCRIÇÃO: Posiciona navios aleatoriamente em um tabuleiro
;; ALGORITMO:
;;   1. Para cada tipo de navio na configuração:
;;      a. Para cada unidade desse tipo:
;;         i. Tenta até 100 vezes encontrar posição válida
;;         ii. Gera posição e orientação aleatórias
;;         iii. Verifica limites e sobreposições
;;         iv. Se válido, marca células com símbolo do navio
;; PARÂMETROS:
;;   - board_sym: Símbolo da variável do tabuleiro (Symbol)
;;   - type_player: 'PLAYER ou 'COMPUTER (Symbol)
;; RETORNO: Nenhum (atualiza tabuleiro e lista de navios)
;; SÍMBOLOS DOS NAVIOS:
;;   - CARRIER: Porta-aviões (5 células)
;;   - BATTLESHIP: Navio de guerra (4 células)
;;   - CRUISER: Cruzador (3 células)
;;   - DESTROYER: Destroyer (2 células)
;;   - SUBMARINE: Submarino (1 célula)
;; --------------------------------------------------------------------
(defun SB_position_ships (board_sym type_player / board_ref ship_list ship_tuple ship_size num_ships 
                                      row col is_horizontal start_row start_col end_row end_col 
                                      ship_symbol attempts ship_placed)
  (setq board_ref (SB_initialize_board nil))
  (setq ship_list (if (eq type_player 'PLAYER) 'SB_ships_player 'SB_ships_computer))
  (set ship_list nil)

  ;; USA *SB_ship_types* QUE AGORA VARIA CONFORME O MODO
  (foreach ship_tuple *SB_ship_types*
    (setq ship_size (car ship_tuple))
    (setq num_ships (cdr ship_tuple))
    
    (setq ship_symbol (cond 
                        ((= ship_size 5) 'CARRIER)
                        ((= ship_size 4) 'BATTLESHIP)
                        ((= ship_size 3) 'CRUISER)
                        ((= ship_size 2) 'DESTROYER)
                        ((= ship_size 1) 'SUBMARINE)
                        (T 'SHIP)
                      ))
    
    (while (> num_ships 0)
      (setq attempts 0)
      (setq ship_placed nil)
      
      (while (and (not ship_placed) (< attempts 100))
        (setq attempts (1+ attempts))
        
        (setq is_horizontal (= (fix (* (SB_randnum) 2)) 0))
        (setq start_row (fix (* (SB_randnum) 8)))
        (setq start_col (fix (* (SB_randnum) 8)))
        
        (setq end_row start_row)
        (setq end_col start_col)
        
        (if is_horizontal
          (setq end_col (+ start_col ship_size -1))
          (setq end_row (+ start_row ship_size -1))
        )
        
        (if (and (< end_row SB_board_size) (< end_col SB_board_size)
                 (>= end_row 0) (>= end_col 0))
          (progn
            (setq ship_placed T)

            ;; Verifica sobreposição
            (if is_horizontal
              (progn 
                (setq col start_col)
                (while (and ship_placed (<= col end_col))
                  (if (SB_get_cell board_ref start_row col) (setq ship_placed nil)) 
                  (setq col (1+ col))
                )
              )
              (progn
                (setq row start_row)
                (while (and ship_placed (<= row end_row))
                  (if (SB_get_cell board_ref row start_col) (setq ship_placed nil)) 
                  (setq row (1+ row))
                )
              )
            )
            
            ;; Colocação final
            (if ship_placed
              (progn
                (if is_horizontal
                  (progn
                    (setq col start_col)
                    (while (<= col end_col)
                      (setq board_ref (SB_update_cell board_ref start_row col ship_symbol))
                      (setq col (1+ col))
                    )
                  )
                  (progn
                    (setq row start_row)
                    (while (<= row end_row)
                      (setq board_ref (SB_update_cell board_ref row start_col ship_symbol))
                      (setq row (1+ row))
                    )
                  )
                )
                (set ship_list (cons (list ship_symbol 0 ship_size) (eval ship_list)))
                (setq num_ships (1- num_ships))
              )
            )
          )
        )
      )
      
      (if (not ship_placed)
        (progn
          (princ (strcat "\nERRO: Não foi possível posicionar " (vl-princ-to-string ship_symbol)))
          (setq num_ships 0)
        )
      )
    )
  )
  
  (set board_sym board_ref)
)

;; ====================================================================
;; SEÇÃO 8: ATUALIZAÇÃO VISUAL
;; ====================================================================

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_update_board_display
;; DESCRIÇÃO: Atualiza a exibição gráfica de ambos os tabuleiros no DCL
;; ALGORITMO:
;;   1. Para cada célula (0,0) a (7,7):
;;      a. Tabuleiro jogador: Mostra navios e tiros recebidos
;;      b. Tabuleiro computador: Mostra apenas tiros do jogador
;;      c. Configura action_tile para células clicáveis do inimigo
;; MAPEAMENTO DE SLIDES:
;;   - Água: "WATER"
;;   - Acerto: "HIT"
;;   - Erro: "MISS"
;;   - Porta-aviões: "SHIP1"
;;   - Navio de guerra: "SHIP2"
;;   - Cruzador: "SHIP3"
;;   - Destroyer: "SHIP4"
;;   - Submarino: "SHIP5"
;; --------------------------------------------------------------------
(defun SB_update_board_display ( / row col)
  (setq rows SB_board_size)
  (setq cols SB_board_size)
  (setq row 0)
  (while (< row rows)
    (setq col 0)
    (while (< col cols)
      
      ;; Tabuleiro do Jogador (esquerda)
      (setq key_p (strcat "cell_P_" (itoa row) "_" (itoa col)))
      (setq val_p (SB_get_cell SB_board_player row col)) 
      
      (setq slide-name-p
        (cond
          ((= val_p 'HIT) "HIT") 
          ((= val_p 'MISS) "MISS") 
          ((= val_p 'CARRIER) "SHIP1")
          ((= val_p 'BATTLESHIP) "SHIP2")
          ((= val_p 'CRUISER) "SHIP3")
          ((= val_p 'DESTROYER) "SHIP4")
          ((= val_p 'SUBMARINE) "SHIP5")
          (val_p "SHIP1")
          (T "WATER")
        )
      )
      
      (SB_ShowSld key_p slide-name-p 143) ; 143 = azul claro
      
      ;; Tabuleiro do Computador (direita)
      (setq key_c (strcat "cell_C_" (itoa row) "_" (itoa col)))
      (setq val_player_shot (SB_get_cell SB_board_computer row col))
      
      (setq slide-name-c
        (cond
          ((= val_player_shot 'HIT) "HIT") 
          ((= val_player_shot 'MISS) "MISS") 
          (T "WATER")
        )
      )
      
      (SB_ShowSld key_c slide-name-c 143)
      (action_tile key_c (strcat "(SB_cell_clicked \"" key_c "\")"))
      
      (setq col (1+ col))
    )
    (setq row (1+ row))
  )
  (princ)
)

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_is_ship_sunk
;; DESCRIÇÃO: Verifica se um navio foi completamente afundado
;; PARÂMETROS:
;;   - ship_type: Tipo do navio (Symbol)
;;   - board_to_check: Tabuleiro a verificar (List)
;; RETORNO: T (verdadeiro) se navio afundado, nil caso contrário
;; LÓGICA: Verifica se há alguma célula com o símbolo do navio
;; --------------------------------------------------------------------
(defun SB_is_ship_sunk (ship_type board_to_check / row col found_any)
  (setq found_any nil)
  (setq row 0)
  (while (< row 8)
    (setq col 0)
    (while (< col 8)
      (if (eq (SB_get_cell board_to_check row col) ship_type)
        (setq found_any T)
      )
      (setq col (1+ col))
    )
    (setq row (1+ row))
  )
  (not found_any)
)

;; ====================================================================
;; SEÇÃO 9: LÓGICA DO JOGO - TIROS E TURNOS
;; ====================================================================

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_check_sunk
;; DESCRIÇÃO: Verifica se um navio específico foi afundado
;; PARÂMETROS:
;;   - ship_symbol: Símbolo do navio (Symbol)
;;   - target_ships: Símbolo da lista de navios (Symbol)
;; RETORNO: ship_symbol se afundado, nil caso contrário
;; LÓGICA: Compara hits atuais com hits máximos do navio
;; EFEITO COLATERAL: Remove navio afundado da lista
;; --------------------------------------------------------------------
(defun SB_check_sunk (ship_symbol target_ships / current_ships is_sunk)
  (setq current_ships (eval target_ships))
  (setq is_sunk nil)
  (setq new_ships nil)
  (foreach ship current_ships
    (if (eq (car ship) ship_symbol)
      (progn
        (setq num_hits (cadr ship))
        (setq max_hits (caddr ship))
        (if (>= num_hits max_hits)
          (setq is_sunk T)
          (setq new_ships (cons ship new_ships))
        )
      )
      (setq new_ships (cons ship new_ships))
    )
  )
  (set target_ships (reverse new_ships))
  (if is_sunk (setq is_sunk ship_symbol))
  is_sunk
)

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_make_shot
;; DESCRIÇÃO: Executa um tiro em uma posição específica
;; PARÂMETROS:
;;   - board_target: Tabuleiro alvo (Symbol)
;;   - board_shot: Tabuleiro de tiros (Symbol)
;;   - row: Linha do tiro (0-7)
;;   - col: Coluna do tiro (0-7)
;;   - current_player: Jogador atirando (Symbol)
;; RETORNO: Lista (resultado navio_afundado)
;; FLUXO:
;;   1. Verifica se acertou navio
;;   2. Atualiza contagem de hits do navio
;;   3. Marca tabuleiro de tiros
;;   4. Atualiza tabuleiro adversário (se necessário)
;;   5. Retorna resultado
;; --------------------------------------------------------------------
(defun SB_make_shot (board_target board_shot row col current_player / piece_at_target ship_type result sunk_ship)
  (setq piece_at_target (SB_get_cell (eval board_target) row col))
  
  (if piece_at_target ; Acertou navio
    (progn
      (setq result 'HIT)
      (setq ship_type piece_at_target)
      
      ;; Atualiza contagem de hits do navio
      (setq ships_var (if (eq board_target 'SB_board_computer) 'SB_ships_computer 'SB_ships_player))
      (setq current_ships (eval ships_var))
      (setq new_ships nil)
      (foreach ship current_ships
        (if (eq (car ship) ship_type)
          (setq new_ships (cons (list ship_type (1+ (cadr ship)) (caddr ship)) new_ships))
          (setq new_ships (cons ship new_ships))
        )
      )
      (set ships_var (reverse new_ships))

      ;; Verifica se afundou
      (setq sunk_ship (SB_check_sunk ship_type ships_var))
    )
    (progn ; Errou
      (setq result 'MISS)
      (setq sunk_ship nil)
    )
  )
  
  ;; Atualiza tabuleiro de tiros
  (set board_shot (SB_update_cell (eval board_shot) row col result))
  
  ;; Atualiza tabuleiro adversário (para visualização)
  (if (eq board_target 'SB_board_player) 
    (setq SB_board_player (SB_update_cell SB_board_player row col result))
  )
  
  (list result sunk_ship)
)

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_end_game_dialog
;; DESCRIÇÃO: Finaliza o jogo e mostra mensagem de vitória
;; PARÂMETROS:
;;   - winner: "JOGADOR" ou "COMPUTADOR" (String)
;; RETORNO: Nenhum
;; EFEITOS:
;;   1. Atualiza status no DCL
;;   2. Imprime mensagem no console
;;   3. Define estado do jogo como 'ENDED
;;   4. Atualiza display final
;; --------------------------------------------------------------------
(defun SB_end_game_dialog (winner)
  ;; Calcula estatísticas do jogo
  (setq stats (SB_get_mode_stats))
  (setq total_ships (car stats))
  (setq total_cells (cadr stats))
  
  (set_tile "turn_status" 
    (strcat "FIM DE JOGO: " winner " VENCEU!\n"
            "Modo: " 
            (cond
              ((eq *SB_game_mode* 'FAST) "RÁPIDO")
              ((eq *SB_game_mode* 'CLASSIC) "CLÁSSICO")
              ((eq *SB_game_mode* 'CHALLENGE) "DESAFIADOR")
              (T "PADRÃO")
            )
            " | Navios: " (itoa total_ships)
            " | Células: " (itoa total_cells)
    )
  )
  (princ (strcat "\nFIM DE JOGO: " winner " VENCEU!"))
  (setq SB_game_state 'ENDED) 
  (SB_update_board_display) 
  (princ)
)

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_switch_turn
;; DESCRIÇÃO: Alterna o turno entre jogador e computador
;; FLUXO:
;;   - Se turno do jogador: passa para computador, chama IA
;;   - Se turno do computador: passa para jogador, atualiza display
;; RETORNO: Nenhum
;; EFEITOS COLATERAIS:
;;   - Atualiza SB_player_turn
;;   - Atualiza texto de status no DCL
;;   - Limpa SB_selected_target
;; --------------------------------------------------------------------
(defun SB_switch_turn ()
  (setq SB_selected_target nil)
  (if (eq SB_player_turn 'JOGADOR)
    (progn
      (setq SB_player_turn 'COMPUTADOR)
      (set_tile "turn_status" "COMPUTADOR (IA Avançada Calculando...)")
      (princ "\nTurno do Computador (IA Avançada)...")
      (redraw)
      (SB_computer_shoot_advanced)
    )
    (progn
      (setq SB_player_turn 'JOGADOR)
      (set_tile "turn_status" "JOGADOR (Seu Turno: Tabuleiro INIMIGO)")
      (SB_update_board_display)
    )
  )
)

;; ====================================================================
;; SEÇÃO 10: INTELIGÊNCIA ARTIFICIAL AVANÇADA
;; ====================================================================

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_computer_shoot_advanced
;; DESCRIÇÃO: Lógica principal da IA avançada para o turno do computador
;; ESTRATÉGIAS EM HIERARQUIA:
;;   1. DESTRUIÇÃO: Se acertos prévios, foca em células adjacentes
;;      a. Detecta direção do navio
;;      b. Ataca nas extremidades da direção identificada
;;   2. BUSCA PROBABILÍSTICA: Se fase 1 não aplicável
;;      a. Usa padrão de grade (chequerboard)
;;      b. Se padrão esgotado, usa cálculo de probabilidade
;;   3. FALLBACK: Busca aleatória sistemática
;;   4. ÚLTIMO RECURSO: Busca célula por célula
;; PARÂMETROS: Nenhum
;; RETORNO: Nenhum (executa tiro e alterna turno)
;; LOGS: Mensagens detalhadas no console para debugging
;; --------------------------------------------------------------------
(defun SB_computer_shoot_advanced (/ row col shot_result prob_grid target_coord
                                   hunting_idx valid_targets target_idx
                                   direction_targets attempts found
                                   cell_content row_try col_try i j)
  
  (setq row nil)
  (setq col nil)
  
  ;; Inicializa padrão de busca se necessário
  (if (null *SB_ai_hunting_pattern*)
    (progn
      (setq *SB_ai_hunting_pattern* (SB_generate_hunting_pattern))
      (princ "\n[IA] Padrão de busca inicializado.")
    )
  )
  
  ;; 1. FASE DE DESTRUIÇÃO INTELIGENTE (com direção)
  (if (and *SB_ai_targets_hit* (not (member 'DESTROYED *SB_ai_last_hits*)))
    (progn
      (princ "\n[IA] Fase de DESTRUIÇÃO (Targeting Inteligente).")
      
      ;; Atualiza últimos acertos
      (setq *SB_ai_last_hits* *SB_ai_targets_hit*)
      
      ;; Detecta direção do navio
      (setq *SB_ai_ship_direction* (SB_detect_ship_direction *SB_ai_last_hits*))
      
      (if *SB_ai_ship_direction*
        (princ (strcat "\n[IA] Direção detectada: " (vl-princ-to-string *SB_ai_ship_direction*)))
        (princ "\n[IA] Direção ainda não determinada.")
      )
      
      ;; Encontra alvos baseado na direção (se conhecida)
      (if *SB_ai_ship_direction*
        ;; Se direção conhecida, foca nela
        (progn
          ;; Ordena acertos para encontrar extremos
          (if (eq *SB_ai_ship_direction* 'HORIZONTAL)
            (progn
              ;; Ordena por coluna
              (setq sorted_hits (vl-sort *SB_ai_last_hits* 
                (function (lambda (a b) (< (cadr a) (cadr b))))))
              ;; Tenta ambos lados
              (setq left_end (car sorted_hits))
              (setq right_end (last sorted_hits))
              
              ;; Tenta esquerda
              (setq test_col (1- (cadr left_end)))
              (if (and (>= test_col 0) 
                       (not (member (SB_get_cell SB_board_player (car left_end) test_col) '(HIT MISS))))
                (progn
                  (setq row (car left_end))
                  (setq col test_col)
                )
                ;; Tenta direita
                (progn
                  (setq test_col (1+ (cadr right_end)))
                  (if (and (< test_col 8) 
                           (not (member (SB_get_cell SB_board_player (car right_end) test_col) '(HIT MISS))))
                    (progn
                      (setq row (car right_end))
                      (setq col test_col)
                    )
                  )
                )
              )
            )
            ;; Direção VERTICAL
            (progn
              ;; Ordena por linha
              (setq sorted_hits (vl-sort *SB_ai_last_hits* 
                (function (lambda (a b) (< (car a) (car b))))))
              ;; Tenta ambos extremos
              (setq top_end (car sorted_hits))
              (setq bottom_end (last sorted_hits))
              
              ;; Tenta acima
              (setq test_row (1- (car top_end)))
              (if (and (>= test_row 0) 
                       (not (member (SB_get_cell SB_board_player test_row (cadr top_end)) '(HIT MISS))))
                (progn
                  (setq row test_row)
                  (setq col (cadr top_end))
                )
                ;; Tenta abaixo
                (progn
                  (setq test_row (1+ (car bottom_end)))
                  (if (and (< test_row 8) 
                           (not (member (SB_get_cell SB_board_player test_row (cadr bottom_end)) '(HIT MISS))))
                    (progn
                      (setq row test_row)
                      (setq col (cadr bottom_end))
                    )
                  )
                )
              )
            )
          )
        )
        ;; Se direção desconhecida, busca em cruz
        (progn
          (setq last_hit (car *SB_ai_last_hits*))
          (setq valid_targets (SB_get_valid_adjacent_targets (car last_hit) (cadr last_hit) 'SB_board_player))
          
          (if valid_targets
            (progn
              (setq target_idx (fix (* (SB_randnum) (length valid_targets))))
              (setq target_coord (nth target_idx valid_targets))
              (setq row (car target_coord))
              (setq col (cadr target_coord))
              (princ (strcat "\n[IA] Alvo em cruz selecionado: (" (itoa row) ", " (itoa col) ")"))
            )
          )
        )
      )
    )
  )
  
  ;; 2. FASE DE BUSCA PROBABILÍSTICA (se não encontrou alvo na destruição)
  (if (or (not row) (not col))
    (progn
      ;; Calcula grade de probabilidade
      (setq prob_grid (SB_calculate_probability_grid))
      
      ;; Tenta usar padrão de grade primeiro
      (setq found nil)
      (foreach coord *SB_ai_hunting_pattern*
        (if (and (not found) 
                 (not (member (SB_get_cell SB_board_player (car coord) (cadr coord)) '(HIT MISS))))
          (progn
            (setq row (car coord))
            (setq col (cadr coord))
            (setq found T)
            (princ (strcat "\n[IA] Usando padrão de grade: (" (itoa row) ", " (itoa col) ")"))
          )
        )
      )
      
      ;; Se padrão de grade não encontrou, usa probabilidade
      (if (not found)
        (progn
          (setq best_cell (SB_find_highest_probability_cell prob_grid))
          (if best_cell
            (progn
              (setq row (car best_cell))
              (setq col (cadr best_cell))
              (princ (strcat "\n[IA] Célula de alta probabilidade: (" (itoa row) ", " (itoa col) ")"))
            )
          )
        )
      )
    )
  )
  
  ;; 3. FALLBACK: Busca aleatória (só se tudo mais falhar)
  (if (or (not row) (not col))
    (progn
      (princ "\n[IA] Fallback para busca aleatória.")
      (setq attempts 0)
      (setq found nil)
      
      (while (and (not found) (< attempts 64))
        (setq attempts (1+ attempts))
        (setq row_try (fix (* (SB_randnum) 8)))
        (setq col_try (fix (* (SB_randnum) 8)))
        
        (if (and (>= row_try 0) (< row_try 8)
                 (>= col_try 0) (< col_try 8))
          (progn
            (setq cell_content (SB_get_cell SB_board_player row_try col_try))
            (if (not (member cell_content '(HIT MISS)))
              (progn
                (setq row row_try)
                (setq col col_try)
                (setq found T)
              )
            )
          )
        )
      )
      
      ;; Último recurso: busca sistemática
      (if (not found)
        (progn
          (princ "\n[IA] Busca sistemática (último recurso).")
          (setq i 0)
          (while (and (not found) (< i 8))
            (setq j 0)
            (while (and (not found) (< j 8))
              (setq cell_content (SB_get_cell SB_board_player i j))
              (if (not (member cell_content '(HIT MISS)))
                (progn
                  (setq row i)
                  (setq col j)
                  (setq found T)
                )
              )
              (setq j (1+ j))
            )
            (setq i (1+ i))
          )
        )
      )
    )
  )
  
  ;; 4. VERIFICAÇÃO FINAL DE SEGURANÇA
  (cond
    ((not (and row col))
      (princ "\n[ERRO CRÍTICO] IA não conseguiu encontrar célula!")
      (setq row 0)
      (setq col 0))
    
    ((or (< row 0) (>= row 8) (< col 0) (>= col 8))
      (princ (strcat "\n[ERRO] Coordenadas inválidas corrigidas: (" (itoa row) ", " (itoa col) ")"))
      (setq row (max 0 (min row 7)))
      (setq col (max 0 (min col 7))))
  )
  
  (princ (strcat "\n[IA] Atirando em: (" (itoa row) ", " (itoa col) ")"))
  
  ;; 5. REALIZA O TIRO
  (setq shot_result (SB_make_shot 'SB_board_player 'SB_board_player row col 'COMPUTADOR))
  (princ (strcat "\nIA atira em: (" (itoa row) ", " (itoa col) "). Resultado: " (vl-princ-to-string (car shot_result))))

  ;; 6. ATUALIZA ESTRATÉGIA APÓS TIRO
  (if (eq (car shot_result) 'HIT)
    (progn
      (setq *SB_ai_targets_hit* (cons (list row col) *SB_ai_targets_hit*))
      (setq *SB_ai_last_hits* *SB_ai_targets_hit*)
      (princ (strcat "\n[IA] Acerto! Total: " (itoa (length *SB_ai_targets_hit*))))
    )
    (princ "\n[IA] Erro.")
  )
  
  ;; 7. VERIFICA SE NAVIO AFUNDOU
  (if (cadr shot_result)
    (progn
      (princ (strcat "\n[IA] NAVIO AFUNDADO: " (vl-princ-to-string (cadr shot_result))))
      
      (SB_update_remaining_ships (cadr shot_result))
      
      (setq *SB_ai_targets_hit* nil)
      (setq *SB_ai_last_hits* nil)
      (setq *SB_ai_ship_direction* nil)
      
      (princ "\n[IA] Resetando estratégia para novo navio.")
    )
  )
  
  ;; 8. ATUALIZA DISPLAY E MUDANÇA DE TURNO
  (SB_update_board_display)
  (redraw)
  
  (if (null SB_ships_player)
    (SB_end_game_dialog "COMPUTADOR")
    (SB_switch_turn)
  )
)

;; ====================================================================
;; SEÇÃO 11: INTERAÇÃO DO JOGADOR
;; ====================================================================

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_cell_clicked
;; DESCRIÇÃO: Manipula clique do jogador em uma célula do tabuleiro
;; VALIDAÇÕES:
;;   1. Turno deve ser do jogador
;;   2. Jogo deve estar em estado 'PLAYING
;;   3. Clique deve ser no tabuleiro do computador (direita)
;;   4. Célula não deve ter sido anteriormente atingida
;; PARÂMETROS:
;;   - key: Identificador da célula clicada (String)
;; FORMATO DO KEY: "cell_C_row_col" ou "cell_P_row_col"
;; FLUXO:
;;   1. Extrai coordenadas do key
;;   2. Verifica validade do tiro
;;   3. Executa tiro com SB_make_shot
;;   4. Atualiza display
;;   5. Verifica fim de jogo ou alterna turno
;; --------------------------------------------------------------------
(defun SB_cell_clicked (key / row_str col_str row col target_board cell_status shot_result)
  (if (and (eq SB_player_turn 'JOGADOR) (eq SB_game_state 'PLAYING))
    (progn 
      (setq target_board (substr key 6 1)) ; 'P' ou 'C'
      (setq row_str (substr key 8 1))
      (setq col_str (substr key 10 1))
      (setq row (atoi row_str))
      (setq col (atoi col_str))
      
      (if (eq target_board "C") ; Jogador só pode atirar no tabuleiro do Computador
        (progn
          (setq cell_status (SB_get_cell SB_board_computer row col))
          
          (if (or (eq cell_status 'HIT) (eq cell_status 'MISS))
            (princ "\nVocê já atirou nesta posição.")
            (progn
              (setq shot_result (SB_make_shot 'SB_board_computer 'SB_board_computer row col 'JOGADOR))
              
              (princ (strcat "\nJOGADOR atira em: (" (itoa row) ", " (itoa col) "). Resultado: " (vl-princ-to-string (car shot_result))))
              
              (if (cadr shot_result)
                (princ (strcat "\nJOGADOR afundou navio: " (vl-princ-to-string (cadr shot_result))))
              )
              
              (SB_update_board_display)
              
              (if (null SB_ships_computer)
                (SB_end_game_dialog "JOGADOR")
                (SB_switch_turn)
              )
            )
          )
        )
        (princ "\nClique ignorado. Atire no tabuleiro do INIMIGO (Direita).")
      )
    )
    (princ (strcat "\nClique ignorado. Jogo no estado: " (vl-princ-to-string SB_game_state)))
  )
  (princ)
)

;; --------------------------------------------------------------------
;; FUNÇÃO: SB_get_mode_stats
;; DESCRIÇÃO: Retorna estatísticas do modo de jogo atual
;; PARÂMETROS: Nenhum
;; RETORNO: Lista com (total_navios total_celulas)
;; --------------------------------------------------------------------
(defun SB_get_mode_stats ()
  (setq total_ships 0)
  (setq total_cells 0)
  
  (foreach ship_tuple *SB_ship_types*
    (setq ship_size (car ship_tuple))
    (setq ship_count (cdr ship_tuple))
    (setq total_ships (+ total_ships ship_count))
    (setq total_cells (+ total_cells (* ship_size ship_count)))
  )
  
  (list total_ships total_cells)
)


;; ====================================================================
;; SEÇÃO 12: FUNÇÃO PRINCIPAL E INICIALIZAÇÃO
;; ====================================================================

;; --------------------------------------------------------------------
;; FUNÇÃO: C:SEABATTLE_8X8
;; DESCRIÇÃO: Comando principal do AutoCAD para iniciar o jogo
;; FLUXO:
;;   1. Carrega arquivo DCL
;;   2. Inicializa diálogo
;;   3. Configura elementos gráficos (logos, separadores)
;;   4. Inicializa jogo
;;   5. Configura actions para botões
;;   6. Inicia loop do diálogo
;;   7. Descarrega DCL ao final
;; RETORNO: Nenhum
;; COMANDO AUTOCAD: SEABATTLE_8X8
;; --------------------------------------------------------------------
(defun C:SEABATTLE_8X8 ( / SB_dcl_id)
  ;; 1. Carrega arquivo DCL
  (setq SB_dcl_id (load_dialog "SeaBattle_8x8.dcl"))
  
  ;; 2. Verifica se diálogo carregou corretamente
  (if (not (new_dialog "SeaBattle_dialog" SB_dcl_id))
    (exit)
  )
  
  ;; 3. Configura elementos de interface
  (mode_tile "#arkz" 1)
  (mode_tile "descricao" 1)
  
  ;; 4. Carrega elementos gráficos
  (SB_ShowSld "#img_logo" "ArkZLogo" -2)
  (SB_ShowSld "sep1" "Separato" -2)
  (SB_ShowSld "sep2" "Separato" -2)
  (SB_ShowSld "sep3" "Separato" -2)
  
  ;; 5. Configura controles de modo
  (SB_setup_mode_controls)
  
  ;; 6. Inicializa jogo (com modo padrão CLASSIC)
  (setq *SB_game_mode* 'CLASSIC)
  (SB_initialize_game_SeaBattle)
  
  ;; 7. Configura actions para botões
  (action_tile "restart" "(SB_initialize_game_SeaBattle)")
  (action_tile "cancel" "(done_dialog)")
  (action_tile "help" 	"(SeaBattle_8x8_help)")
    
  ;; 8. Inicia loop principal do diálogo
  (start_dialog)
  
  ;; 9. Descarrega DCL ao final
  (unload_dialog SB_dcl_id)
  (princ)
)

;;;===========================================================================
;;; FUNÇÃO DE AJUDA
;;;===========================================================================
;;;---------------------------------------------------------------------------
;;; StringWrap - Lee Mac, 2011 (modificado)
(defun StringWrap (str len / pos)
  (if (< len (strlen str))
    (cons
      (substr str 1
        (cond
          ((setq pos (vl-string-position 32 (substr str 1 len) nil t)))
          ((setq pos (1- len)) len)
        )
      )
      (StringWrap (substr str (+ 2 pos)) len)
    )
    (list str)
  )
)

;;;---------------------------------------------------------------------------
;;; Lê linhas de um arquivo de texto - Chat-GPT, 2024
(defun read-lines (filepath / file lines line)
  (setq lines nil)
  (if (and (setq filepath (findfile filepath))
           (setq file (open filepath "r")))
    (progn
      (while (setq line (read-line file))
        (setq lines (append lines (list line)))
      )
      (close file)
    )
    (progn
      (alert (strcat "Arquivo não encontrado: " filepath))
      nil
    )
  )
  lines
)

;;;---------------------------------------------------------------------------
;;; Processa texto para exibição em list_box
(defun process-text-for-display (lines max-width)
  (if lines
    (apply 'append 
      (mapcar '(lambda (line) (StringWrap line max-width)) lines)
    )
    (list "Nenhuma informação disponível.")
  )
)

;;;---------------------------------------------------------------------------
;;; Função SeaBattle_8x8_help
(defun SeaBattle_8x8_help (/ dcl_id lines display-text)
  ;; Verifica existência do arquivo SeaBattle_8x8.txt
  (if (not (findfile "SeaBattle_8x8.txt"))
    (progn
      (alert "O arquivo SeaBattle_8x8.txt não foi encontrado.\n\nO programa de ajuda não será apresentado.")
      (princ)  ;; Retorna silenciosamente sem abrir o DCL
    )
    (progn
      ;; Arquivo existe, prossegue com a abertura do diálogo
      (if (and (setq dcl_id (load_dialog "SeaBattle_8x8.dcl"))
               (new_dialog "SeaBattle_8x8_help" dcl_id))
        (progn
          ;; Carrega e exibe o texto do arquivo de ajuda
          (if (setq lines (read-lines "SeaBattle_8x8.txt"))
            (progn
              (setq display-text (process-text-for-display lines 60))
              (start_list "lstAbout")
              (foreach line display-text
                (add_list line)
              )
              (end_list)
            )
            ;; Se não conseguir ler o arquivo (mesmo existindo)
            (progn
              (start_list "lstAbout")
              (foreach line '("Erro ao ler o arquivo de ajuda." 
                             "Verifique se o arquivo não está corrompido."
                             ""
                             "Contate o suporte técnico.")
                (add_list line)
              )
              (end_list)
            )
          )
          
          ;; Exibe logo
          (SB_ShowSld "#img_logo" "ArkZLogo" -2)
          
          ;; Preenche dados do registro
          (setq reg1 "ARK-Z ARQUITETURA LTDA - Ezequiel M Rezende")
          (setq reg2 "Aplicativos para o Autocad 2013 - 2026")
          (setq reg3 "SeaBattle_8x8 - License GNU GPLv3 © 2026 Ezequiel M Rezende")
          (setq reg4 "https://em-rezende.github.io/")
          (setq regdat (strcat reg1 "\n" reg2 "\n" reg3 "\n" reg4))
          (set_tile "reg_dat" regdat)
		  
          ;; Define ação do botão OK
          (action_tile "btnOK" "(done_dialog 1)")
          
          ;; Inicia o diálogo
          (start_dialog)
          (unload_dialog dcl_id)
        )
        (alert "Erro ao carregar diálogo de ajuda.\nVerifique o arquivo SeaBattle_8x8.dcl.")
      )
    )
  )
  (princ)
)
;;;

;; ====================================================================
;; SEÇÃO 13: MENSAGEM DE CARREGAMENTO
;; ====================================================================

;; --------------------------------------------------------------------
;; MENSAGEM: Mensagem ao carregar o script
;; DESCRIÇÃO: Informa ao usuário que o jogo foi carregado e como iniciar
;; EXECUÇÃO: Automática ao carregar o arquivo .lsp
;; --------------------------------------------------------------------
(princ "\SeaBattle_8x8 carregado. Digite SeaBattle_8x8 para iniciar o jogo.")
(princ)

;; ====================================================================
;; FIM DO SCRIPT SEA BATTLE 8x8
;; ====================================================================