;; ====================================================================
;; PUZZLE 4X4 (15-PUZZLE) - VARIÁVEIS E FUNÇÕES PREFIXADAS P4_
;; ====================================================================

;; Variáveis globais de estado (prefixadas)
(setq P4_dcl_id nil)
(setq P4_board nil) ; O tabuleiro 4x4 (1-15 e nil)
(setq P4_solved_board '((1 2 3 4) (5 6 7 8) (9 10 11 12) (13 14 15 nil))) ; O estado de vitória
(setq P4_board_size 4) ; Dimensão do tabuleiro

;; Variável global para a semente do gerador aleatório (prefixada)
(setq P4_seed (getvar "DATE"))

;; ====================================================================
;; FUNÇÕES AUXILIARES DE MANIPULAÇÃO DE LISTAS (Prefixadas)
;; ====================================================================

(defun P4_drop (n lst)
  (if (<= n 0) lst (if (cdr lst) (P4_drop (1- n) (cdr lst)) nil))
)
(defun P4_take (n lst)
  (if (or (<= n 0) (null lst)) nil (cons (car lst) (P4_take (1- n) (cdr lst))))
)
(defun P4_update_cell (board row col value)
  (append (P4_take row board) (list (append (P4_take col (nth row board)) (list value) (P4_drop (1+ col) (nth row board)))) (P4_drop (1+ row) board))
)

;; Gerador de Números Pseudoaleatórios (Prefixada)
;; Retorna um número real entre 0 e 1.
(defun P4_randnum (/ modulus multiplier increment)
  (setq modulus    65536
        multiplier 25173
        increment  13849
        P4_seed  (rem (+ (* multiplier P4_seed) increment) modulus) ; Usa P4_seed
  )
  (/ P4_seed modulus) ; Retorna um valor entre 0 e 1.0
)

;; ====================================================================
;; FUNÇÕES DE EXIBIÇÃO GRÁFICA (Prefixadas)
;; ====================================================================

;; Função para exibir slides (Prefixada e adaptada para 4x4 SLB)
(defun P4_ShowSld (tile slide color_index / x y)
  (setq x (dimx_tile tile))
  (setq y (dimy_tile tile))
  (start_image tile)
  
  (fill_image 0 0 x y color_index) 
  
  (slide_image 0 0 x y
    (strcat "Puzzle_4x4" " (" (vl-filename-base slide) ")") ; Nome da biblioteca alterado
  )
  (end_image)
)

;; FUNÇÃO PRINCIPAL DE ATUALIZAÇÃO DO DISPLAY DO TABULEIRO
(defun P4_update_board_display ()
  (setq max_index (1- P4_board_size)) ; Usa P4_board_size
  
  (foreach row '(0 1 2 3)
    (foreach col '(0 1 2 3)
      (setq key (strcat "cell_" (itoa row) "_" (itoa col)))
      (setq val (nth col (nth row P4_board))) ; Usa P4_board
      
      (if (null val)
          (progn
            (setq slide-name "BLANK")
            (setq color_index 253)
            (action_tile key "") 
          )
          (progn
            (setq slide-name (itoa val)) 
            (setq color_index 254) 
            (action_tile key "") 
          )
      )
      
      (P4_ShowSld key slide-name color_index) ; Usa P4_ShowSld
    )
  )
  
  (P4_enable_legal_moves) ; Usa P4_enable_legal_moves
  (princ)
)

;; ====================================================================
;; FUNÇÕES DE CONTROLE DE JOGO (Prefixadas)
;; ====================================================================

;; Comando principal para iniciar o jogo 4x4
(defun c:Puzzle_4x4 ()
  (setq P4_dcl_id (load_dialog "Puzzle_4x4.dcl")) 
  (if (not (new_dialog "puzzle_4x4" P4_dcl_id)) ; Usa P4_dcl_id
    (progn
      (princ "\nErro ao carregar a caixa de diálogo Puzzle 4x4!")
      (unload_dialog P4_dcl_id)
      (exit)
    )
  )
;;
  (mode_tile "#arkz" 1)
;;
  (P4_ShowSld "#img_logo" "ArkZLogo" -2)
  (P4_ShowSld "sep1"  "Separato" -2)
  (P4_ShowSld "sep2"  "Separato" -2)
  (P4_ShowSld "sep3"  "Separato" -2)
;;
  (P4_initialize_game) ; Chama a função prefixada
  (start_dialog)
  
  (unload_dialog P4_dcl_id) 
  (princ)
)

(defun P4_initialize_game ()
  (setq P4_board P4_solved_board) ; Usa P4_board e P4_solved_board
  (P4_update_board_display)
  (set_tile "status" "Clique em Reiniciar (Shuffle) para começar.")
  
  ;; As ações de tile chamam as funções prefixadas
  (action_tile "reset" "(P4_shuffle_board)") 
  (action_tile "sair" "(done_dialog 0)")
  (action_tile "help" "(P4_Puzzle_Help)") ; Chama a função de ajuda prefixada
)

;; Função para embaralhar o tabuleiro
(defun P4_shuffle_board (/ num_moves move_coords row_nil col_nil legal_moves max_index move_index)
  (setq max_index (1- P4_board_size)) ; Usa P4_board_size
  (setq P4_board P4_solved_board) 
  (setq num_moves 200) ; Aumentado o número de movimentos para 4x4

  (repeat num_moves
    ;; 1. Encontra a posição do espaço vazio (nil)
    (setq row_nil -1 col_nil -1)
    (foreach r '(0 1 2 3)
      (foreach c '(0 1 2 3)
        (if (null (nth c (nth r P4_board)))
          (setq row_nil r col_nil c)
        )
      )
    )
    
    ;; 2. Gera uma lista de coordenadas de peças vizinhas (movimentos legais)
    (setq legal_moves nil)
    (if (<= 0 (1- row_nil) max_index) (setq legal_moves (cons (list (1- row_nil) col_nil) legal_moves))) ; Cima
    (if (<= 0 (1+ row_nil) max_index) (setq legal_moves (cons (list (1+ row_nil) col_nil) legal_moves))) ; Baixo
    (if (<= 0 (1- col_nil) max_index) (setq legal_moves (cons (list row_nil (1- col_nil)) legal_moves))) ; Esquerda
    (if (<= 0 (1+ col_nil) max_index) (setq legal_moves (cons (list row_nil (1+ col_nil)) legal_moves))) ; Direita
    
    ;; 3. Escolhe um movimento aleatório (se houver) e executa a troca
    (if legal_moves
      (progn
        (setq move_index (fix (* (P4_randnum) (length legal_moves)))) ; Usa P4_randnum
        (setq move_coords (nth move_index legal_moves))

        (setq piece_val (nth (cadr move_coords) (nth (car move_coords) P4_board)))
        
        (setq P4_board (P4_update_cell P4_board row_nil col_nil piece_val)) ; Usa P4_update_cell
        (setq P4_board (P4_update_cell P4_board (car move_coords) (cadr move_coords) nil))
      )
    )
  )
  
  (P4_update_board_display)
  (set_tile "status" "Jogo embaralhado. Encontre a solução!")
)

;; Função para desabilitar todos os cliques e reabilitar apenas os movimentos legais
(defun P4_enable_legal_moves (/ row_nil col_nil keys max_index)
  (setq max_index (1- P4_board_size))
  
  (setq keys '("cell_0_0" "cell_0_1" "cell_0_2" "cell_0_3"
               "cell_1_0" "cell_1_1" "cell_1_2" "cell_1_3"
               "cell_2_0" "cell_2_1" "cell_2_2" "cell_2_3"
               "cell_3_0" "cell_3_1" "cell_3_2" "cell_3_3"))
  
  ;; Desabilita todos os botões primeiro
  (foreach key keys (action_tile key ""))
  
  ;; 1. Encontra a posição do espaço vazio (nil)
  (setq row_nil -1 col_nil -1)
  (foreach r '(0 1 2 3)
    (foreach c '(0 1 2 3)
      (if (null (nth c (nth r P4_board)))
        (setq row_nil r col_nil c)
      )
    )
  )
  
  ;; 2. Habilita os vizinhos
  (if (<= 0 (1- row_nil) max_index) 
    (action_tile (strcat "cell_" (itoa (1- row_nil)) "_" (itoa col_nil)) (strcat "(P4_cell_clicked \"cell_" (itoa (1- row_nil)) "_" (itoa col_nil) "\")")) ; Chama P4_cell_clicked
  ) 
  (if (<= 0 (1+ row_nil) max_index) 
    (action_tile (strcat "cell_" (itoa (1+ row_nil)) "_" (itoa col_nil)) (strcat "(P4_cell_clicked \"cell_" (itoa (1+ row_nil)) "_" (itoa col_nil) "\")"))
  ) 
  (if (<= 0 (1- col_nil) max_index) 
    (action_tile (strcat "cell_" (itoa row_nil) "_" (itoa (1- col_nil))) (strcat "(P4_cell_clicked \"cell_" (itoa row_nil) "_" (itoa (1- col_nil)) "\")"))
  ) 
  (if (<= 0 (1+ col_nil) max_index) 
    (action_tile (strcat "cell_" (itoa row_nil) "_" (itoa (1+ col_nil))) (strcat "(P4_cell_clicked \"cell_" (itoa row_nil) "_" (itoa (1+ col_nil)) "\")"))
  ) 
)

;; Função de clique do usuário (move a peça)
(defun P4_cell_clicked (key / row col row_str col_str row_nil col_nil piece_val max_index)
  (setq max_index (1- P4_board_size))
  (setq row_str (substr key 6 1))
  (setq col_str (substr key 8 1))
  (setq row (atoi row_str))
  (setq col (atoi col_str))

  ;; 1. Encontra a posição do espaço vazio (nil)
  (setq row_nil -1 col_nil -1)
  (foreach r '(0 1 2 3)
    (foreach c '(0 1 2 3)
      (if (null (nth c (nth r P4_board)))
        (setq row_nil r col_nil c)
      )
    )
  )
  
  ;; 2. Verifica se a célula clicada é adjacente
  (if (and 
        (numberp row_nil) 
        (numberp col_nil)
        (or 
          (and (= row row_nil) (= (abs (- col col_nil)) 1)) ; Movimento Horizontal
          (and (= col col_nil) (= (abs (- row row_nil)) 1)) ; Movimento Vertical
        )
      )
    (progn
      (setq piece_val (nth col (nth row P4_board)))
      
      (setq P4_board (P4_update_cell P4_board row_nil col_nil piece_val))
      (setq P4_board (P4_update_cell P4_board row col nil))
      
      (P4_update_board_display) 
      
      (if (P4_check_win) ; Usa P4_check_win
        (progn
          (alert "Parabéns! Você resolveu o Puzzle 4x4!")
          (set_tile "status" "PARABÉNS! Jogo Resolvido.")
          (P4_enable_legal_moves)
        )
        (set_tile "status" "Continue movendo as peças.")
      )
    )
  )
  (princ)
)

;; Verifica se o estado atual do tabuleiro é igual ao estado resolvido
(defun P4_check_win ()
  (equal P4_board P4_solved_board)
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
;;; Função P4_Puzzle_Help
(defun P4_Puzzle_Help (/ dcl_id lines display-text)
  ;; Verifica existência do arquivo Puzzle_4x4.txt
  (if (not (findfile "Puzzle_4x4.txt"))
    (progn
      (alert "O arquivo Puzzle_4x4.txt não foi encontrado.\n\nO programa de ajuda não será apresentado.")
      (princ)  ;; Retorna silenciosamente sem abrir o DCL
    )
    (progn
      ;; Arquivo existe, prossegue com a abertura do diálogo
      (if (and (setq dcl_id (load_dialog "Puzzle_4x4.dcl"))
               (new_dialog "P4_Puzzle_Help" dcl_id))
        (progn
          ;; Carrega e exibe o texto do arquivo de ajuda
          (if (setq lines (read-lines "Puzzle_4x4.txt"))
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
          (P4_ShowSld "#img_logo" "ArkZLogo" -2)
          
          ;; Preenche dados do registro
          (setq reg1 "ARK-Z ARQUITETURA LTDA - Ezequiel M Rezende")
          (setq reg2 "Aplicativos para o Autocad 2013 - 2026")
          (setq reg3 "Puzzle_4x4 - License GNU GPLv3 © 2026 Ezequiel M Rezende")
          (setq reg4 "https://em-rezende.github.io/")
          (setq regdat (strcat reg1 "\n" reg2 "\n" reg3 "\n" reg4))
          (set_tile "reg_dat" regdat)
		  
          ;; Define ação do botão OK
          (action_tile "btnOK" "(done_dialog 1)")
          
          ;; Inicia o diálogo
          (start_dialog)
          (unload_dialog dcl_id)
        )
        (alert "Erro ao carregar diálogo de ajuda.\nVerifique o arquivo Puzzle_4x4.dcl.")
      )
    )
  )
  (princ)
)
;;;

(princ "\nPuzzle_4x4 carregado. Digite Puzzle_4x4 para iniciar o jogo.")
(princ)