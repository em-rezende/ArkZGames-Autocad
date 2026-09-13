;; ======================================================================
;; WORDLE.LSP - Versao com image_button e teclado virtual completo
;; Jogo Wordle para AutoCAD
;; ======================================================================
; Inicío: 2025/12/16 - Ezequiel M Rezende
; - Com ajuda do DeepSeek
;; ======================================================================

;; ----------------------------------------------------------------------
;; VARIÁVEIS GLOBAIS DE ESTADO
;; ----------------------------------------------------------------------
(setq WD_dcl_id nil)           ;; ID do diálogo DCL carregado
(setq WD_secret_word nil)      ;; Palavra secreta a ser adivinhada
(setq WD_word_list nil)        ;; Lista de palavras do arquivo CSV
(setq WD_current_attempt 1)    ;; Tentativa atual (1-6)
(setq WD_game_active nil)      ;; Jogo em andamento (T = ativo, nil = inativo)
(setq WD_seed (getvar "DATE")) ;; Semente para randomizaçao baseada na data
(setq WD_used_letters nil)     ;; Lista de letras já tentadas e seus status
(setq WD_words_loaded 0)       ;; Contador de palavras carregadas

;; ======================================================================
;; FUNÇOES AUXILIARES
;; ======================================================================

;; ----------------------------------------------------------------------
;; NOME: WD_randnum
;; PROPÓSITO: Gera número aleatório entre 0 e 1 usando algoritmo linear congruente
;; ENTRADA: Nenhuma (usa variável global WD_seed)
;; SAÍDA: Número real entre 0 e 1
;; ----------------------------------------------------------------------
(defun WD_randnum (/ modulus multiplier increment)
  ;; Gera número aleatório entre 0 e 1
  (setq modulus    65536
        multiplier 25173
        increment  13849)
  (setq WD_seed (rem (+ (* WD_seed multiplier) increment) modulus))
  (/ WD_seed modulus)
)

;; ----------------------------------------------------------------------
;; NOME: WD_load_word_list
;; PROPÓSITO: Carrega palavras de 5 letras do arquivo CSV
;; ENTRADA: Nenhuma
;; SAÍDA: Número de palavras carregadas (inteiro)
;; NOTAS: Procura arquivo Wordle.csv, usa lista de fallback se não encontrar
;; ----------------------------------------------------------------------
(defun WD_load_word_list (/ file_path line word_count)
  ;; Carrega palavras do arquivo CSV
  (setq WD_word_list nil)
  (setq word_count 0)
  
  (setq file_path (findfile "Wordle.csv"))
  
  (if file_path
    (progn
      (setq file (open file_path "r"))
      
      (if file
        (progn
          (while (setq line (read-line file))
            ;; Remove espaços e converte para maiúsculas
            (setq word (strcase (vl-string-trim " \t\r\n" line)))
            
            ;; Verifica se é palavra de 5 letras
            (if (= (strlen word) 5)
              (progn
                (setq WD_word_list (cons word WD_word_list))
                (setq word_count (1+ word_count))
              )
            )
          )
          (close file)
          
          (setq WD_words_loaded word_count)
          (princ (strcat "\n" (itoa word_count) " palavras carregadas do arquivo Wordle.csv"))
        )
        (progn
          (princ "\nErro: Nao foi possível abrir o arquivo Wordle.csv")
          (setq WD_words_loaded 0)
        )
      )
    )
    (progn
      (princ "\nErro: Arquivo Wordle.csv nao encontrado")
      (setq WD_words_loaded 0)
    )
  )
  
  ;; Se nao carregou palavras, usa lista de fallback
  (if (null WD_word_list)
    (progn
      (setq WD_word_list '("CARRO" "CASAL" "CASAO" "CAIXA" "CINCO" "DADOS" "DANCA" 
                           "DENTE" "FOCUS" "FOGAO" "GATOS" "GOLFO" "HOTEL" "IGREJA"
                           "JOGOS" "LARGO" "LEITE" "LIMAO" "PASTO" "PEDRA" "QUASE" 
                           "RADIO" "SAPOS" "TIGRE" "UNHAS" "VASOS" "XALES" "ZEBRA"))
      (setq WD_words_loaded (length WD_word_list))
      (princ (strcat "\nUsando lista de fallback com " (itoa WD_words_loaded) " palavras"))
    )
  )
  
  WD_words_loaded
)

;; ----------------------------------------------------------------------
;; NOME: WD_select_random_word
;; PROPÓSITO: Seleciona palavra aleatória da lista carregada
;; ENTRADA: Nenhuma (usa WD_word_list)
;; SAÍDA: String com palavra secreta
;; ----------------------------------------------------------------------
(defun WD_select_random_word ()
  ;; Seleciona uma palavra aleatória da lista
  (if WD_word_list
    (progn
      (setq idx (fix (* (WD_randnum) (length WD_word_list))))
      (nth idx WD_word_list)
    )
    "CARRO"  ;; Palavra padrao se lista vazia
  )
)

;; ----------------------------------------------------------------------
;; NOME: WD_validate_word
;; PROPÓSITO: Verifica se palavra existe na lista de palavras válidas
;; ENTRADA: word (String) - palavra a validar
;; SAÍDA: T se palavra existe, nil caso contrário
;; ----------------------------------------------------------------------
(defun WD_validate_word (word)
  ;; Valida se a palavra existe na lista
  (member (strcase word) WD_word_list)
)

;; ----------------------------------------------------------------------
;; NOME: WD_check_letters
;; PROPÓSITO: Compara palpite com palavra secreta e determina status das letras
;; ENTRADA: 
;;   guess (String) - palpite do jogador
;;   secret (String) - palavra secreta
;; SAÍDA: Lista de 5 elementos com status:
;;   0 = letra nao existe (vermelho)
;;   1 = letra existe mas posiçao errada (amarelo)  
;;   2 = letra correta na posiçao correta (verde)
;; ----------------------------------------------------------------------
(defun WD_check_letters (guess secret / result i guess_char secret_char
                                  temp_count count_in_secret already_marked j temp_result)
  ;; Compara guess com secret e retorna lista com resultados
  ;; 0 = letra nao existe (vermelho)
  ;; 1 = letra existe mas posiçao errada (amarelo)  
  ;; 2 = letra correta na posiçao correta (verde)
  (setq result '())
  (setq i 0)
  
  ;; Primeiro passada: marca posiçoes corretas
  (while (< i 5)
    (setq guess_char (substr guess (1+ i) 1))
    (setq secret_char (substr secret (1+ i) 1))
    
    (if (= guess_char secret_char)
      (setq result (cons 2 result))
      (setq result (cons 0 result))
    )
    
    (setq i (1+ i))
  )
  
  (setq result (reverse result))
  
  ;; Segunda passada: marca letras na posiçao errada
  (setq i 0)
  (while (< i 5)
    (setq guess_char (substr guess (1+ i) 1))
    (setq secret_char (substr secret (1+ i) 1))
    
    (if (/= guess_char secret_char)
      (progn
        ;; Conta ocorrencias da letra em secret
        (setq count_in_secret 0)
        (setq j 0)
        (while (< j 5)
          (if (= guess_char (substr secret (1+ j) 1))
            (setq count_in_secret (1+ count_in_secret))
          )
          (setq j (1+ j))
        )
        
        ;; Conta quantas já foram marcadas
        (setq already_marked 0)
        (setq j 0)
        (while (< j 5)
          (if (and (= (nth j result) 2) 
                   (= guess_char (substr guess (1+ j) 1))
                   (= guess_char (substr secret (1+ j) 1)))
            (setq already_marked (1+ already_marked))
          )
          (if (and (= (nth j result) 1) 
                   (= guess_char (substr guess (1+ j) 1)))
            (setq already_marked (1+ already_marked))
          )
          (setq j (1+ j))
        )
        
        ;; Se ainda há ocorrencias nao marcadas
        (if (> count_in_secret already_marked)
          (progn
            (setq temp_result '())
            (setq j 0)
            (while (< j 5)
              (if (and (= j i) (= (nth j result) 0))
                (setq temp_result (cons 1 temp_result))
                (setq temp_result (cons (nth j result) temp_result))
              )
              (setq j (1+ j))
            )
            (setq result (reverse temp_result))
          )
        )
      )
    )
    
    (setq i (1+ i))
  )
  
  result
)

;; ----------------------------------------------------------------------
;; NOME: WD_get_color_index
;; PROPÓSITO: Retorna índice de cor AutoCAD baseado no status da letra
;; ENTRADA: status (Integer) - 0, 1 ou 2
;; SAÍDA: Índice de cor AutoCAD:
;;   12 = Vermelho (letra nao existe)
;;   40 = Amarelo (letra na posiçao errada)
;;   82 = Verde (letra correta)
;;   255 = Cinza claro (fundo padrao)
;; ----------------------------------------------------------------------
(defun WD_get_color_index (status)
  ;; Retorna índice de cor baseado no status
  ;; 0 = vermelho (letra nao existe)
  ;; 1 = amarelo (letra na posiçao errada)
  ;; 2 = verde (letra correta)
  ;; -1 = cinza (vazio/nao tentado)
  (cond
    ((= status 0) 12)   ;; Vermelho
    ((= status 1) 40)   ;; Amarelo  
    ((= status 2) 82)   ;; Verde
    (T 255)            ;; Cinza claro (fundo padrao)
  )
)

;; ----------------------------------------------------------------------
;; NOME: WD_get_keyboard_color
;; PROPÓSITO: Retorna cor para tecla do teclado virtual baseado no status
;; ENTRADA: letter (String) - letra a verificar
;; SAÍDA: Índice de cor AutoCAD para a tecla
;; ----------------------------------------------------------------------
(defun WD_get_keyboard_color (letter / status)
  ;; Retorna a cor para a tecla do teclado virtual
  (setq status (cadr (assoc letter WD_used_letters)))
  (cond
    ((= status 2) 82)   ;; Verde - posiçao correta
    ((= status 1) 40)   ;; Amarelo - letra existe
    ((= status 0) 12)   ;; Vermelho - letra nao existe
    (T 255)            ;; Cinza - nao usado
  )
)

;; ----------------------------------------------------------------------
;; NOME: WD_ShowSld
;; PROPÓSITO: Exibe slide (imagem) em tile DCL com cor de fundo
;; ENTRADA: 
;;   tile (String) - nome do tile DCL
;;   slide (String) - nome do slide (sem extensao)
;;   color (Integer) - índice de cor AutoCAD para fundo
;; SAÍDA: Nenhuma (atualiza display)
;; ----------------------------------------------------------------------
(defun WD_ShowSld (tile slide color / x y)
  ;; Exibe a imagem (Slide) na DCL com nome correto
  (setq x (dimx_tile tile))
  (setq y (dimy_tile tile))
  (start_image tile)
  (fill_image 0 0 x y color) 
  (slide_image 0 0 x y
    (strcat "Wordle" " (" (vl-filename-base slide) ")")
  )
  (end_image)
  (princ)
)

;; ----------------------------------------------------------------------
;; NOME: WD_update_keyboard_display
;; PROPÓSITO: Atualiza display do teclado virtual com image_buttons
;; ENTRADA: Nenhuma (usa WD_used_letters)
;; SAÍDA: Nenhuma (atualiza interface)
;; ----------------------------------------------------------------------
(defun WD_update_keyboard_display ()
  ;; Atualiza o display do teclado virtual com image_buttons
  (setq letters '("A" "B" "C" "D" "E" "F" "G" "H" "I" "J" 
                  "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T" 
                  "U" "V" "W" "X" "Y" "Z"))
  
  (foreach letter letters
    (setq key (strcat "key_" letter))
    (setq color_index (WD_get_keyboard_color letter))
    
    ;; Para teclas nao usadas (cinza), usar cinza médio
    (setq bg_color (if (= color_index 255) 252 color_index))
    
    ;; Mostra o slide da letra com cor de fundo
    (WD_ShowSld key (strcat "LETTER_" letter) bg_color)
  )
  
  ;; Atualiza botoes BACK e ENTER
  (WD_ShowSld "key_back" "BACK" 250)  ;; Cinza médio
  (WD_ShowSld "key_enter" "ENTER" 250)  ;; Azul para ENTER
)

;; ----------------------------------------------------------------------
;; NOME: WD_show_letter
;; PROPÓSITO: Exibe letra no tabuleiro do Wordle
;; ENTRADA:
;;   row (Integer) - linha (1-6)
;;   col (Integer) - coluna (1-5)
;;   letter (String) - letra a exibir (ou "" para vazio)
;;   color_index (Integer) - índice de cor para fundo
;; SAÍDA: Nenhuma (atualiza interface)
;; ----------------------------------------------------------------------
(defun WD_show_letter (row col letter color_index)
  ;; Exibe uma letra no tabuleiro
  (setq key (strcat "cell_" (itoa row) "_" (itoa col)))
  
  ;; Mostra o slide da letra com cor de fundo
  (if (and letter (/= letter ""))
    (progn
      ;; Para células do tabuleiro, use uma cor de fundo mais escura
      ;; Se color_index for 255 (cinza claro), mude para 252 (cinza médio)
      (setq bg_color (if (= color_index 255) 252 color_index))
      (WD_ShowSld key (strcat "LETTER_" letter) bg_color)
    )
    ;; Célula vazia - apenas cor de fundo
    (progn
      (setq x (dimx_tile key))
      (setq y (dimy_tile key))
      (start_image key)
      ;; Use cinza médio (250) em vez de cinza claro (255)
      (fill_image 0 0 x y 255)
      (end_image)
    )
  )
)

;; ----------------------------------------------------------------------
;; NOME: WD_update_used_letters
;; PROPÓSITO: Atualiza lista de letras usadas com melhor status encontrado
;; ENTRADA:
;;   guess (String) - palpite atual
;;   result (List) - lista de status das letras
;; SAÍDA: Nenhuma (atualiza WD_used_letters)
;; NOTAS: Mantém o melhor status (2 > 1 > 0) para cada letra
;; ----------------------------------------------------------------------
(defun WD_update_used_letters (guess result)
  ;; Atualiza a lista de letras usadas com melhor status
  (setq i 0)
  (while (< i 5)
    (setq letter (substr guess (1+ i) 1))
    (setq status (nth i result))
    
    ;; Verifica se a letra já está na lista
    (setq existing (assoc letter WD_used_letters))
    
    (if existing
      ;; Atualiza se novo status for melhor
      (if (< (cadr existing) status)
        (progn
          (setq WD_used_letters (vl-remove existing WD_used_letters))
          (setq WD_used_letters (cons (list letter status) WD_used_letters))
        )
      )
      ;; Adiciona nova letra
      (setq WD_used_letters (cons (list letter status) WD_used_letters))
    )
    
    (setq i (1+ i))
  )
)

;; ----------------------------------------------------------------------
;; NOME: WD_update_display
;; PROPÓSITO: Atualiza informações textuais do jogo na interface
;; ENTRADA: Nenhuma (usa variáveis globais)
;; SAÍDA: Nenhuma (atualiza tiles DCL)
;; ----------------------------------------------------------------------
(defun WD_update_display ()
  ;; Atualiza a exibiçao do jogo
  (set_tile "attempt_display" (strcat "Tentativa: " (itoa WD_current_attempt) "/6"))
  (set_tile "word_info" (strcat "Palavras: " (itoa WD_words_loaded)))
  
  (if WD_game_active
    (set_tile "status" "Digite uma palavra de 5 letras e clique em 'Tentar' ou use o teclado virtual.")
    (set_tile "status" "Clique em 'Novo Jogo' para começar.")
  )
)

;; ----------------------------------------------------------------------
;; NOME: WD_clear_board
;; PROPÓSITO: Limpa todas as células do tabuleiro (6x5)
;; ENTRADA: Nenhuma
;; SAÍDA: Nenhuma (atualiza interface)
;; ----------------------------------------------------------------------
(defun WD_clear_board ()
  ;; Limpa o tabuleiro (todas as células vazias com fundo cinza)
  (setq row 1)
  (while (<= row 6)
    (setq col 1)
    (while (<= col 5)
      (WD_show_letter row col "" 255)
      (setq col (1+ col))
    )
    (setq row (1+ row))
  )
)

;; ----------------------------------------------------------------------
;; NOME: WD_show_result
;; PROPÓSITO: Exibe resultado completo de uma tentativa no tabuleiro
;; ENTRADA:
;;   row (Integer) - linha a exibir (1-6)
;;   guess (String) - palpite
;;   result (List) - lista de status das letras
;; SAÍDA: Nenhuma (atualiza interface)
;; ----------------------------------------------------------------------
(defun WD_show_result (row guess result)
  ;; Exibe o resultado de uma tentativa no tabuleiro
  (setq col 1)
  (while (<= col 5)
    (setq letter (substr guess col 1))
    (setq status (nth (1- col) result))
    (setq color_index (WD_get_color_index status))
    
    ;; Exibe a letra com cor de fundo
    (WD_show_letter row col letter color_index)
    
    (setq col (1+ col))
  )
)

;; ----------------------------------------------------------------------
;; NOME: WD_new_game
;; PROPÓSITO: Inicializa um novo jogo Wordle
;; ENTRADA: Nenhuma
;; SAÍDA: Nenhuma (reinicia estado do jogo)
;; NOTAS: Seleciona nova palavra secreta, reinicia tentativas, limpa tabuleiro
;; ----------------------------------------------------------------------
(defun WD_new_game ()
  ;; Inicia um novo jogo
  (WD_load_word_list)  ;; Carrega palavras se necessário
  
  (setq WD_secret_word (WD_select_random_word))
  (setq WD_current_attempt 1)
  (setq WD_game_active T)
  (setq WD_used_letters nil)
  
  (WD_clear_board)
  (set_tile "current_word" "")
  
  ;; Atualizar teclado
  (WD_update_keyboard_display)
  (WD_update_display)
  
  (set_tile "status" "Novo jogo iniciado! Tente adivinhar a palavra de 5 letras.")
  
  ;; Debug (remover na versao final)
  (princ (strcat "\nPalavra secreta: " WD_secret_word))
)

;; ----------------------------------------------------------------------
;; NOME: WD_submit_guess
;; PROPÓSITO: Processa uma tentativa do jogador
;; ENTRADA: Nenhuma (lê do tile "current_word")
;; SAÍDA: Nenhuma (atualiza estado do jogo)
;; NOTAS: Valida palavra, verifica acerto, atualiza tentativas
;; ----------------------------------------------------------------------
(defun WD_submit_guess ()
  ;; Processa uma tentativa
  (if (not WD_game_active)
    (alert "Inicie um novo jogo primeiro!")
    (progn
      (setq guess (strcase (get_tile "current_word")))
      
      ;; Valida a palavra
      (cond
        ((/= (strlen guess) 5)
         (alert "A palavra deve ter exatamente 5 letras!")
        )
        ((not (WD_validate_word guess))
         (alert "Palavra nao encontrada no dicionário!")
        )
        (T
         ;; Processa a tentativa
         (setq result (WD_check_letters guess WD_secret_word))
         
         ;; Exibe o resultado na linha atual
         (WD_show_result WD_current_attempt guess result)
         
         ;; Atualiza letras usadas e teclado
         (WD_update_used_letters guess result)
         (WD_update_keyboard_display)
         
         ;; Verifica se acertou
         (setq all_correct T)
         (setq i 0)
         (while (< i 5)
           (if (/= (nth i result) 2)
             (setq all_correct nil)
           )
           (setq i (1+ i))
         )
         
         (if all_correct
           (progn
             (setq WD_game_active nil)
             (set_tile "status" (strcat "PARABÉNS! Voce acertou em " (itoa WD_current_attempt) " tentativas!"))
             (alert (strcat "Parabéns! A palavra era: " WD_secret_word))
           )
           (progn
             ;; Avança para próxima tentativa
             (setq WD_current_attempt (1+ WD_current_attempt))
             
             (if (> WD_current_attempt 6)
               (progn
                 (setq WD_game_active nil)
                 (set_tile "status" (strcat "FIM DE JOGO! A palavra era: " WD_secret_word))
                 (alert (strcat "Fim de jogo! A palavra era: " WD_secret_word))
               )
               (progn
                 (set_tile "current_word" "")
                 (WD_update_display)
                 
                 (set_tile "status" (strcat "Continue tentando! Tentativa " (itoa WD_current_attempt) "/6"))
               )
             )
           )
         )
        )
      )
    )
  )
)

;; ----------------------------------------------------------------------
;; NOME: WD_add_letter_to_input
;; PROPÓSITO: Adiciona letra ao campo de entrada via teclado virtual
;; ENTRADA: letter (String) - letra a adicionar
;; SAÍDA: Nenhuma (atualiza tile "current_word")
;; ----------------------------------------------------------------------
(defun WD_add_letter_to_input (letter)
  ;; Adiciona uma letra ao campo de entrada
  (if WD_game_active
    (progn
      (setq current (get_tile "current_word"))
      (if (< (strlen current) 5)
        (set_tile "current_word" (strcat current letter))
      )
    )
  )
)

;; ----------------------------------------------------------------------
;; NOME: WD_remove_last_letter
;; PROPÓSITO: Remove última letra do campo de entrada (BACKSPACE)
;; ENTRADA: Nenhuma
;; SAÍDA: Nenhuma (atualiza tile "current_word")
;; ----------------------------------------------------------------------
(defun WD_remove_last_letter ()
  ;; Remove a última letra do campo de entrada
  (if WD_game_active
    (progn
      (setq current (get_tile "current_word"))
      (if (> (strlen current) 0)
        (set_tile "current_word" (substr current 1 (1- (strlen current))))
      )
    )
  )
)

;; ======================================================================
;; FUNÇAO PRINCIPAL
;; ======================================================================

;; ----------------------------------------------------------------------
;; NOME: C:WORDLE
;; PROPÓSITO: Função principal - inicia o jogo Wordle
;; ENTRADA: Nenhuma (comando AutoCAD)
;; SAÍDA: Nenhuma (executa interface gráfica)
;; NOTAS: Carrega DCL, configura callbacks, inicia diálogo
;; ----------------------------------------------------------------------
(defun C:WORDLE ()
  (setq WD_dcl_id (load_dialog "Wordle.dcl"))
  (if (not (new_dialog "wordle" WD_dcl_id))
    (progn
      (princ "\nErro ao carregar a caixa de diálogo Wordle!")
      (unload_dialog WD_dcl_id)
      (exit)
    )
  )
  
  ;; Configuraçoes iniciais
  (mode_tile "#arkz" 1)
  ;;
  (WD_ShowSld "#img_logo" "ArkZLogo" -2)
  (WD_ShowSld "sep1"  "Separato" -2)
  (WD_ShowSld "sep2"  "Separato" -2)
  (WD_ShowSld "sep3"  "Separato" -2)
  (WD_ShowSld "sep4"  "Separato" -2)
  
  ;; Configura açoes dos botoes principais
  (action_tile "submit" "(WD_submit_guess)")
  (action_tile "new_game" "(WD_new_game)")
  (action_tile "sair" "(progn (done_dialog 0) (princ))")
  (action_tile "help" "(progn (Wordle_Help) (princ))")
  
  ;; Configura açao da caixa de texto
  (action_tile "current_word" 
    "(if (= $reason 1) (if (= (strlen $value) 5) (WD_submit_guess)))")
  
  ;; Configura teclado virtual com image_buttons
  (setq letters '("A" "B" "C" "D" "E" "F" "G" "H" "I" "J" 
                  "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T" 
                  "U" "V" "W" "X" "Y" "Z"))
  
  (foreach letter letters
    (action_tile (strcat "key_" letter) 
      (strcat "(WD_add_letter_to_input \"" letter "\")"))
  )
  
  (action_tile "key_back" "(WD_remove_last_letter)")
  (action_tile "key_enter" "(WD_submit_guess)")
  
  ;; Estado inicial
  (setq WD_game_active nil)
  
  ;; Limpa tabuleiro
  (WD_clear_board)
  
  ;; Inicializa teclado virtual
  (WD_update_keyboard_display)
  
  ;; Carrega lista de palavras
  (WD_load_word_list)
  
  ;; Atualiza display
  (WD_update_display)
  
  (start_dialog)
  (unload_dialog WD_dcl_id)
  (princ)
)


;;; ========================================================================
;;; FUNÇOES DE AJUDA (Prefixadas)
;;; ========================================================================

;; ----------------------------------------------------------------------
;; NOME: WD_StringWrap
;; PROPÓSITO: Quebra string em múltiplas linhas com comprimento máximo
;; ENTRADA:
;;   str (String) - texto a quebrar
;;   len (Integer) - comprimento máximo por linha
;; SAÍDA: Lista de strings (linhas)
;; ----------------------------------------------------------------------
(defun WD_StringWrap ( str len / pos )
	(if (< len (strlen str))
		(cons
			(substr str 1
				(cond
					((setq pos (vl-string-position 32 (substr str 1 len) nil t)))
					((setq pos (1- len)) len)
				)
			)
			(WD_StringWrap (substr str (+ 2 pos)) len)
		); cons
		(list str)
	); if
)

;; ----------------------------------------------------------------------
;; NOME: WD_read_lines
;; PROPÓSITO: Divide texto em linhas usando delimitador de nova linha
;; ENTRADA: text (String) - texto com \n como separador
;; SAÍDA: Lista de strings (linhas)
;; ----------------------------------------------------------------------
(defun WD_read_lines (text / lines pos line)
  (setq lines nil)
  (while (setq pos (vl-string-search "\n" text))
    (setq line (substr text 1 pos)) 
    (setq text (substr text (+ pos 2))) 
    (setq lines (append lines (list line))) 
  )
  (if (/= text "")
    (setq lines (append lines (list text))))
  lines
)

;; ----------------------------------------------------------------------
;; NOME: Wordle_Help
;; PROPÓSITO: Exibe diálogo de ajuda com informações do jogo
;; ENTRADA: Nenhuma
;; SAÍDA: Nenhuma (exibe diálogo)
;; NOTAS: Lê conteúdo de Wordle.txt, formata e exibe
;; ----------------------------------------------------------------------
(defun Wordle_Help ( /  str lst dcl option)
	(setq str "")
	(if (and (setq txt (findfile "Wordle.txt")) 
			(setq txt (open txt "r")))
		(progn
			(while (setq option (read-line txt))
				(setq str (strcat str option "\n")) 
			); while
			(close txt)
		); progn
		(progn
			(alert "O arquivo Wordle.txt nao foi encontrado. \nSaindo do programa...")
			(exit)
		); progn
	); if
	
	(setq str (vl-string-subst "\n" (strcat (chr 13) (chr 10)) str)) 
	(setq str (vl-string-subst "\n" (chr 13) str)) 
	
	(setq lst (WD_read_lines str)) ; Usa WD_read_lines
	(setq lst (apply 'append (mapcar (function (lambda (line) (WD_StringWrap line 60))) lst))) ; Usa WD_StringWrap

	(if (setq dcl (load_dialog "Wordle.dcl")) 
		(progn
			(if (new_dialog "wordle_help" dcl) 
				(progn
					(start_list "lstAbout")
					(foreach line lst
						(add_list line)
					); foreach
					(end_list)
			
					(WD_ShowSld "#img_logo" "ArkZLogo" -2) ; Usa P3_ShowSld
			
					;; Le informaçoes do registro do Windows
;					(setq reg1 (if (= (vl-registry-read "HKEY_CURRENT_USER\\ARK-Z\\user") nil)
;								"Faltando preencher - Nome do usuário"
;								(strcat "Registrado para: " (vl-registry-read "HKEY_CURRENT_USER\\ARK-Z\\user")))
;						reg2 (if (= (vl-registry-read "HKEY_CURRENT_USER\\ARK-Z\\phone") nil)
;								"Faltando preencher - Telefone do usuário"
;								(strcat "Telefone: " (vl-registry-read "HKEY_CURRENT_USER\\ARK-Z\\phone")))
;						reg3 (if (= (vl-registry-read "HKEY_CURRENT_USER\\ARK-Z\\email") nil)
;								"Faltando preencher - E-mail do usuário"
;								(strcat "E-mail: " (vl-registry-read "HKEY_CURRENT_USER\\ARK-Z\\email")))
;						reg4 (if (= (vl-registry-read "HKEY_CURRENT_USER\\ARK-Z\\serial") nil)
;								"Faltando preencher - Número de autorizaçao"
;								(strcat "Ns Autorizaçao: " (vl-registry-read "HKEY_CURRENT_USER\\ARK-Z\\serial"))))
;			            
;					(set_tile "reg_dat" (strcat reg1 "\n" reg2 "\n" reg3 "\n" reg4))
			
					(setq return (start_dialog))
				); progn
				(alert "Incapaz de mostrar o quadro de diálogo")
			); if
			(unload_dialog dcl)
		); progn
	(alert "Incapaz de carregar o Wordle.dlc")
	); if
	(princ)
)

;; ----------------------------------------------------------------------
;; NOME: WD_split_text
;; PROPÓSITO: Divide texto em linhas respeitando comprimento máximo (obsoleta)
;; ENTRADA:
;;   text (String) - texto a dividir
;;   max_len (Integer) - comprimento máximo por linha
;; SAÍDA: Lista de strings
;; NOTAS: Função alternativa para quebra de texto
;; ----------------------------------------------------------------------
(defun WD_split_text (text max_len / words lines current_line word)
  ;; Divide texto em linhas com comprimento máximo
  (setq words (WD_split_string text " "))
  (setq lines nil)
  (setq current_line "")
  
  (foreach word words
    (if (> (strlen (strcat current_line " " word)) max_len)
      (progn
        (setq lines (cons current_line lines))
        (setq current_line word)
      )
      (if (= current_line "")
        (setq current_line word)
        (setq current_line (strcat current_line " " word))
      )
    )
  )
  
  (if (/= current_line "")
    (setq lines (cons current_line lines))
  )
  
  (reverse lines)
)

;; ----------------------------------------------------------------------
;; NOME: WD_split_string
;; PROPÓSITO: Divide string usando delimitador específico (obsoleta)
;; ENTRADA:
;;   text (String) - texto a dividir
;;   delimiter (String) - delimitador
;; SAÍDA: Lista de strings
;; ----------------------------------------------------------------------
(defun WD_split_string (text delimiter / pos result part)
  ;; Divide string por delimitador
  (setq result nil)
  (while (setq pos (vl-string-search delimiter text))
    (setq part (substr text 1 pos))
    (setq text (substr text (+ pos 2)))
    (setq result (cons part result))
  )
  (if (/= text "")
    (setq result (cons text result))
  )
  (reverse result)
)

;; ----------------------------------------------------------------------
;;

(princ "\nWordle (com image_button) carregado. Digite WORDLE para iniciar.")
(princ)
