;; ====================================================================
;; PUZZLE 3X3 (8-PUZZLE) - VARIÁVEIS E FUNÇÕES PREFIXADAS P3_
;; ====================================================================

;; Variáveis globais de estado (prefixadas)
(setq P3_dcl_id nil)
(setq P3_board nil) ; O tabuleiro 3x3 (1-8 e nil)
(setq P3_solved_board '((1 2 3) (4 5 6) (7 8 nil))) ; O estado de vitória

;; Variável global para a semente do gerador aleatório (prefixada)
(setq P3_seed (getvar "DATE"))

;; ====================================================================
;; FUNÇÕES AUXILIARES DE MANIPULAÇÃO DE LISTAS (Prefixadas)
;; ====================================================================

(defun P3_drop (n lst)
  (if (<= n 0) lst (if (cdr lst) (P3_drop (1- n) (cdr lst)) nil))
)
(defun P3_take (n lst)
  (if (or (<= n 0) (null lst)) nil (cons (car lst) (P3_take (1- n) (cdr lst))))
)
(defun P3_update_cell (board row col value)
  (append (P3_take row board) (list (append (P3_take col (nth row board)) (list value) (P3_drop (1+ col) (nth row board)))) (P3_drop (1+ row) board))
)

;; Gerador de Números Pseudoaleatórios (Prefixada)
;; Retorna um número real entre 0 e 1.
(defun P3_randnum (/ modulus multiplier increment)
  (setq modulus    65536
        multiplier 25173
        increment  13849
        P3_seed  (rem (+ (* multiplier P3_seed) increment) modulus)
  )
  (/ P3_seed modulus) ; Retorna um valor entre 0 e 1.0
)

;; ====================================================================
;; FUNÇÕES DE EXIBIÇÃO GRÁFICA (Prefixadas)
;; ====================================================================

;; Função para exibir slides (Prefixada e adaptada para 3x3 SLB)
(defun P3_ShowSld (tile slide color_index / x y)
  (setq x (dimx_tile tile))
  (setq y (dimy_tile tile))
  (start_image tile)
  
  (fill_image 0 0 x y color_index) 
  
  (slide_image 0 0 x y
    (strcat "Puzzle_3x3" " (" (vl-filename-base slide) ")")
  )
  (end_image)
)

;; FUNÇÃO PRINCIPAL DE ATUALIZAÇÃO DO DISPLAY DO TABULEIRO
(defun P3_update_board_display ()
  (foreach row '(0 1 2)
    (foreach col '(0 1 2)
      (setq key (strcat "cell_" (itoa row) "_" (itoa col)))
      (setq val (nth col (nth row P3_board))) ; Usa P3_board
      
      (if (null val)
          (progn
            (setq slide-name "BLANK")
            (setq color_index 253)
            (action_tile key "") ; Desabilita o clique no espaço vazio
          )
          (progn
            (setq slide-name (itoa val)) 
            (setq color_index 254) 
            (action_tile key "") 
          )
      )
      
      (P3_ShowSld key slide-name color_index) ; Usa P3_ShowSld
    )
  )
  
  (P3_enable_legal_moves) ; Usa P3_enable_legal_moves
  (princ)
)

;; ====================================================================
;; FUNÇÕES DE CONTROLE DE JOGO (Prefixadas)
;; ====================================================================

;; Comando principal para iniciar o jogo 3x3
(defun c:Puzzle_3x3 ()
  (setq P3_dcl_id (load_dialog "Puzzle_3x3.dcl")) 
  (if (not (new_dialog "puzzle_3x3" P3_dcl_id)) ; Usa P3_dcl_id
    (progn
      (princ "\nErro ao carregar a caixa de diálogo Puzzle 3x3!")
      (unload_dialog P3_dcl_id)
      (exit)
    )
  )
;;
  (mode_tile "#arkz" 1)
;;
  (P3_ShowSld "#img_logo" "ArkZLogo" -2)
  (P3_ShowSld "sep1"  "Separato" -2)
  (P3_ShowSld "sep2"  "Separato" -2)
  (P3_ShowSld "sep3"  "Separato" -2)
;;
  (P3_initialize_game) ; Chama a função prefixada
  (start_dialog)
  
  (unload_dialog P3_dcl_id) 
  (princ)
)

(defun P3_initialize_game ()
  (setq P3_board P3_solved_board) ; Usa P3_board e P3_solved_board
  (P3_update_board_display) ; Usa P3_update_board_display
  (set_tile "status" "Clique em Reiniciar (Shuffle) para começar.")
  
  ;; As ações de tile chamam as funções prefixadas
  (action_tile "reset" "(P3_shuffle_board)") 
  (action_tile "sair" "(done_dialog 0)")
  (action_tile "help" "(P3_Puzzle_Help)") ; Chama a função de ajuda prefixada
)

;; Função para embaralhar o tabuleiro
(defun P3_shuffle_board (/ num_moves move_coords row_nil col_nil legal_moves move_index)
  (setq P3_board P3_solved_board) ; Usa P3_board
  (setq num_moves 50) 
  
  (repeat num_moves
    ;; 1. Encontra a posição do espaço vazio (nil)
    (setq row_nil -1 col_nil -1)
    (foreach r '(0 1 2)
      (foreach c '(0 1 2)
        (if (null (nth c (nth r P3_board)))
          (setq row_nil r col_nil c)
        )
      )
    )
    
    ;; 2. Gera uma lista de coordenadas de peças vizinhas (movimentos legais)
    (setq legal_moves nil)
    (if (<= 0 (1- row_nil) 2) (setq legal_moves (cons (list (1- row_nil) col_nil) legal_moves)))
    (if (<= 0 (1+ row_nil) 2) (setq legal_moves (cons (list (1+ row_nil) col_nil) legal_moves)))
    (if (<= 0 (1- col_nil) 2) (setq legal_moves (cons (list row_nil (1- col_nil)) legal_moves)))
    (if (<= 0 (1+ col_nil) 2) (setq legal_moves (cons (list row_nil (1+ col_nil)) legal_moves)))
    
    ;; 3. Escolhe um movimento aleatório (se houver) e executa a troca
    (if legal_moves
      (progn
        (setq move_index (fix (* (P3_randnum) (length legal_moves)))) ; Usa P3_randnum
        (setq move_coords (nth move_index legal_moves))

        (setq piece_val (nth (cadr move_coords) (nth (car move_coords) P3_board)))
        
        ;; Move a peça para a posição nil
        (setq P3_board (P3_update_cell P3_board row_nil col_nil piece_val)) ; Usa P3_update_cell
        ;; Move nil para a posição da peça
        (setq P3_board (P3_update_cell P3_board (car move_coords) (cadr move_coords) nil))
      )
    )
  )
  
  (P3_update_board_display)
  (set_tile "status" "Jogo embaralhado. Encontre a solução!")
)

;; Função para desabilitar todos os cliques e reabilitar apenas os movimentos legais
(defun P3_enable_legal_moves (/ row_nil col_nil keys)
  (setq keys '("cell_0_0" "cell_0_1" "cell_0_2" "cell_1_0" "cell_1_1" "cell_1_2" "cell_2_0" "cell_2_1" "cell_2_2"))
  
  ;; Desabilita todos os botões primeiro
  (foreach key keys (action_tile key ""))
  
  ;; 1. Encontra a posição do espaço vazio (nil)
  (setq row_nil -1 col_nil -1)
  (foreach r '(0 1 2)
    (foreach c '(0 1 2)
      (if (null (nth c (nth r P3_board))) ; Usa P3_board
        (setq row_nil r col_nil c)
      )
    )
  )
  
  ;; 2. Habilita os vizinhos (cima, baixo, esquerda, direita)
  (if (<= 0 (1- row_nil) 2) 
    (action_tile (strcat "cell_" (itoa (1- row_nil)) "_" (itoa col_nil)) (strcat "(P3_cell_clicked \"cell_" (itoa (1- row_nil)) "_" (itoa col_nil) "\")")) ; Chama P3_cell_clicked
  ) 
  (if (<= 0 (1+ row_nil) 2) 
    (action_tile (strcat "cell_" (itoa (1+ row_nil)) "_" (itoa col_nil)) (strcat "(P3_cell_clicked \"cell_" (itoa (1+ row_nil)) "_" (itoa col_nil) "\")"))
  ) 
  (if (<= 0 (1- col_nil) 2) 
    (action_tile (strcat "cell_" (itoa row_nil) "_" (itoa (1- col_nil))) (strcat "(P3_cell_clicked \"cell_" (itoa row_nil) "_" (itoa (1- col_nil)) "\")"))
  ) 
  (if (<= 0 (1+ col_nil) 2) 
    (action_tile (strcat "cell_" (itoa row_nil) "_" (itoa (1+ col_nil))) (strcat "(P3_cell_clicked \"cell_" (itoa row_nil) "_" (itoa (1+ col_nil)) "\")"))
  ) 
)

;; Função de clique do usuário (move a peça)
(defun P3_cell_clicked (key / row col row_str col_str row_nil col_nil piece_val)
  (setq row_str (substr key 6 1))
  (setq col_str (substr key 8 1))
  (setq row (atoi row_str))
  (setq col (atoi col_str))

  ;; 1. Encontra a posição do espaço vazio (nil)
  (setq row_nil -1 col_nil -1)
  (foreach r '(0 1 2)
    (foreach c '(0 1 2)
      (if (null (nth c (nth r P3_board))) ; Usa P3_board
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
      (setq piece_val (nth col (nth row P3_board)))
      
      (setq P3_board (P3_update_cell P3_board row_nil col_nil piece_val)) ; Atualiza P3_board
      (setq P3_board (P3_update_cell P3_board row col nil))
      
      (P3_update_board_display) 
      
      (if (P3_check_win) ; Usa P3_check_win
        (progn
          (alert "Parabéns! Você resolveu o Puzzle 3x3!")
          (set_tile "status" "PARABÉNS! Jogo Resolvido.")
          (P3_enable_legal_moves)
        )
        (set_tile "status" "Continue movendo as peças.")
      )
    )
  )
  (princ)
)

;; Verifica se o estado atual do tabuleiro é igual ao estado resolvido
(defun P3_check_win ()
  (equal P3_board P3_solved_board) ; Usa P3_board e P3_solved_board
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
;;; Função P3_Puzzle_Help
(defun P3_Puzzle_Help (/ dcl_id lines display-text)
  ;; Verifica existência do arquivo Puzzle_3x3.txt
  (if (not (findfile "Puzzle_3x3.txt"))
    (progn
      (alert "O arquivo Puzzle_3x3.txt não foi encontrado.\n\nO programa de ajuda não será apresentado.")
      (princ)  ;; Retorna silenciosamente sem abrir o DCL
    )
    (progn
      ;; Arquivo existe, prossegue com a abertura do diálogo
      (if (and (setq dcl_id (load_dialog "Puzzle_3x3.dcl"))
               (new_dialog "P3_Puzzle_Help" dcl_id))
        (progn
          ;; Carrega e exibe o texto do arquivo de ajuda
          (if (setq lines (read-lines "Puzzle_3x3.txt"))
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
          (P3_ShowSld "#img_logo" "ArkZLogo" -2)
          
          ;; Preenche dados do registro
          (setq reg1 "ARK-Z ARQUITETURA LTDA - Ezequiel M Rezende")
          (setq reg2 "Aplicativos para o Autocad 2013 - 2026")
          (setq reg3 "Puzzle_3x3 - License GNU GPLv3 © 2026 Ezequiel M Rezende")
          (setq reg4 "https://em-rezende.github.io/")
          (setq regdat (strcat reg1 "\n" reg2 "\n" reg3 "\n" reg4))
          (set_tile "reg_dat" regdat)
		  
          ;; Define ação do botão OK
          (action_tile "btnOK" "(done_dialog 1)")
          
          ;; Inicia o diálogo
          (start_dialog)
          (unload_dialog dcl_id)
        )
        (alert "Erro ao carregar diálogo de ajuda.\nVerifique o arquivo Puzzle_3x3.dcl.")
      )
    )
  )
  (princ)
)
;;;


(princ "\nPuzzle_3x3 carregado. Digite Puzzle_3x3 para iniciar o jogo.")
(princ)