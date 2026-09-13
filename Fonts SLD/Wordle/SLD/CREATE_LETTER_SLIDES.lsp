;; ======================================================================
;; CREATE_LETTER_SLIDES.LSP
;; Cria slides das letras maiúsculas A-Z para o jogo Wordle
;; ======================================================================

(defun c:CREATE_LETTER_SLIDES (/ letters font_size start_point text_height
                                 old_cmdecho old_osmode old_layer current_layer
                                 letter slides_list)
  
  ;; Salvar configurações atuais
  (setq old_cmdecho (getvar "CMDECHO"))
  (setq old_osmode (getvar "OSMODE"))
  (setq old_layer (getvar "CLAYER"))
  
  ;; Desabilitar eco de comandos
  (setvar "CMDECHO" 0)
  (setvar "OSMODE" 0)  ;; Desabilitar snap
  
  ;; Definir parâmetros
  (setq letters '("A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M"
                  "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z"))
  
  (setq font_size 1.0)
  (setq start_point '(0 0 0))
  (setq text_height 0.7)
  
  ;; Criar layer para as letras
  (if (not (tblsearch "LAYER" "LETTERS"))
    (command "_.LAYER" "_M" "LETTERS" "_C" "7" "LETTERS" "" "")
    (setvar "CLAYER" "LETTERS")
  )
  
  ;; Definir estilo de texto
  (if (not (tblsearch "STYLE" "WORDLE_FONT"))
    (command "_.STYLE" "WORDLE_FONT" "Arial" "0" "1" "0" "_N" "_N" "_N")
  )
  
  ;; Zoom na área -1,-1 a 1,1
  (command "_.ZOOM" "_W" "-1,-1" "1,1")
  
  ;; Lista para armazenar nomes dos slides
  (setq slides_list '())
  
  ;; Criar cada letra e seu slide
  (foreach letter letters
    (princ (strcat "\nCriando slide para a letra: " letter))
    
    ;; Limpar tela
    (command "_.ERASE" "_ALL" "")
    
    ;; Criar texto da letra
    (command "_.TEXT" 
             "_J" "_MC"     ;; Justificação Middle-Center
             "0,0"          ;; Ponto de inserção
             text_height    ;; Altura do texto
             "0"            ;; Rotação
             letter         ;; Texto
    )
    
    ;; Ajustar zoom para garantir que a letra esteja visível
    (command "_.ZOOM" "_E")  ;; Extents
    
    ;; Criar slide
    (setq slide_name (strcat "LETTER_" letter))
    (command "_.MSLIDE" slide_name)
    
    ;; Adicionar à lista
    (setq slides_list (cons slide_name slides_list))
    
    ;; Pequena pausa para garantir que o slide seja criado
    (princ ".")
  )
  
  ;; Restaurar configurações
  (setvar "CMDECHO" old_cmdecho)
  (setvar "OSMODE" old_osmode)
  (setvar "CLAYER" old_layer)
  
  ;; Zoom para a extensão total
  (command "_.ZOOM" "_E")
  
  ;; Exibir resumo
  (princ "\n\n==========================================")
  (princ "\nSLIDES CRIADOS COM SUCESSO!")
  (princ "\n==========================================")
  (princ "\nTotal de slides criados: ")
  (princ (length slides_list))
  
  (princ "\n\nLista de slides criados:")
  (setq counter 1)
  (foreach slide (reverse slides_list)
    (princ (strcat "\n" (itoa counter) ". " slide))
    (setq counter (1+ counter))
  )
  
  (princ "\n\nPara criar a biblioteca de slides (.slb):")
  (princ "\n1. Use o comando SLIDELIB no prompt do AutoCAD")
  (princ "\n2. Digite: SLIDELIB Wordle")
  (princ "\n3. Digite o nome de cada arquivo .sld (LETTER_A.sld, etc.)")
  (princ "\n4. Pressione Enter em uma linha vazia para finalizar")
  (princ "\n\nArquivo Wordle.slb será criado na pasta atual.")
  
  (princ)
)

;; Versão alternativa que cria slides com cores diferentes
(defun c:CREATE_COLORED_LETTER_SLIDES (/ letters colors color_names
                                        old_cmdecho old_osmode old_layer
                                        letter color color_name slide_name
                                        counter)
  
  ;; Salvar configurações atuais
  (setq old_cmdecho (getvar "CMDECHO"))
  (setq old_osmode (getvar "OSMODE"))
  (setq old_layer (getvar "CLAYER"))
  
  ;; Desabilitar eco de comandos
  (setvar "CMDECHO" 0)
  (setvar "OSMODE" 0)
  
  ;; Definir parâmetros
  (setq letters '("A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M"
                  "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z"))
  
  ;; Cores: 1-Vermelho, 2-Amarelo, 3-Verde, 7-Branco
  (setq colors '(7 2 1 3))  ;; Branco, Amarelo, Vermelho, Verde
  (setq color_names '("WHITE" "YELLOW" "RED" "GREEN"))
  
  ;; Criar layer para as letras
  (if (not (tblsearch "LAYER" "LETTERS"))
    (command "_.LAYER" "_M" "LETTERS" "_C" "7" "LETTERS" "" "")
    (setvar "CLAYER" "LETTERS")
  )
  
  ;; Definir estilo de texto
  (if (not (tblsearch "STYLE" "WORDLE_FONT"))
    (command "_.STYLE" "WORDLE_FONT" "Arial" "0" "1" "0" "_N" "_N" "_N")
  )
  
  ;; Zoom na área -1,-1 a 1,1
  (command "_.ZOOM" "_W" "-1,-1" "1,1")
  
  (setq counter 0)
  
  ;; Criar cada letra em cada cor
  (foreach letter letters
    (setq color_index 0)
    
    (foreach color colors
      (setq color_name (nth color_index color_names))
      (setq color_index (1+ color_index))
      
      ;; Limpar tela
      (command "_.ERASE" "_ALL" "")
      
      ;; Criar texto da letra com cor
      (command "_.COLOR" color)
      (command "_.TEXT" 
               "_J" "_MC"     ;; Justificação Middle-Center
               "0,0"          ;; Ponto de inserção
               "0.7"          ;; Altura do texto
               "0"            ;; Rotação
               letter         ;; Texto
      )
      
      ;; Voltar para cor branca (BYLAYER)
      (command "_.COLOR" "_BYLAYER")
      
      ;; Ajustar zoom
      (command "_.ZOOM" "_E")
      
      ;; Criar slide
      (setq slide_name (strcat "LETTER_" letter "_" color_name))
      (command "_.MSLIDE" slide_name)
      
      (setq counter (1+ counter))
      (princ (strcat "\nCriado slide " (itoa counter) ": " slide_name))
    )
  )
  
  ;; Restaurar configurações
  (setvar "CMDECHO" old_cmdecho)
  (setvar "OSMODE" old_osmode)
  (setvar "CLAYER" old_layer)
  
  ;; Zoom para a extensão total
  (command "_.ZOOM" "_E")
  
  ;; Exibir resumo
  (princ "\n\n==========================================")
  (princ "\nSLIDES COLORIDOS CRIADOS COM SUCESSO!")
  (princ (strcat "\nTotal: " (itoa counter) " slides"))
  (princ "\n==========================================")
  
  (princ "\n\nCada letra tem 4 versões coloridas:")
  (princ "\n- WHITE: Letra branca (padrão)")
  (princ "\n- YELLOW: Letra amarela (posição errada)")
  (princ "\n- RED: Letra vermelha (não existe na palavra)")
  (princ "\n- GREEN: Letra verde (posição correta)")
  
  (princ)
)

;; Script para criar um arquivo de lista para o SLIDELIB
(defun c:CREATE_SLIDE_LIST (/ letters colors color_names file
                             letter color_index color_name)
  
  (setq letters '("A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M"
                  "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z"))
  
  (setq colors '(7 2 1 3))
  (setq color_names '("WHITE" "YELLOW" "RED" "GREEN"))
  
  ;; Criar arquivo de lista
  (setq file (open "slide_list.txt" "w"))
  
  (if file
    (progn
      ;; Escrever cabeçalho
      (write-line ";; Lista de slides para Wordle.slb" file)
      (write-line ";; Criado automaticamente por CREATE_LETTER_SLIDES.lsp" file)
      (write-line "" file)
      
      ;; Escrever cada slide
      (foreach letter letters
        (setq color_index 0)
        
        (foreach color colors
          (setq color_name (nth color_index color_names))
          (setq color_index (1+ color_index))
          
          (setq slide_name (strcat "LETTER_" letter "_" color_name))
          (write-line slide_name file)
        )
      )
      
      (close file)
      
      (princ "\nArquivo 'slide_list.txt' criado com sucesso!")
      (princ "\nPara criar a biblioteca Wordle.slb, execute no prompt:")
      (princ "\n  SLIDELIB Wordle < slide_list.txt")
      
      ;; Também criar versão simplificada apenas com letras brancas
      (setq file2 (open "slide_list_simple.txt" "w"))
      
      (if file2
        (progn
          (write-line ";; Apenas letras brancas" file2)
          (foreach letter letters
            (write-line (strcat "LETTER_" letter "_WHITE") file2)
          )
          (close file2)
          (princ "\n\nArquivo 'slide_list_simple.txt' criado (apenas letras brancas).")
        )
      )
    )
    (princ "\nErro ao criar arquivo!")
  )
  
  (princ)
)

;; Função para criar slides rapidamente (apenas letras brancas)
(defun c:CREATE_SIMPLE_LETTERS (/ letters old_cmdecho old_osmode letter)
  
  (setq old_cmdecho (getvar "CMDECHO"))
  (setq old_osmode (getvar "OSMODE"))
  
  (setvar "CMDECHO" 0)
  (setvar "OSMODE" 0)
  
  (setq letters '("A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M"
                  "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z"))
  
  ;; Configurar texto
  (command "_.STYLE" "WORDLE" "Arial" "0" "1" "0" "_N" "_N" "_N")
  (command "_.ZOOM" "_W" "-2,-2" "2,2")
  
  (foreach letter letters
    ;; Limpar tela
    (command "_.ERASE" "_ALL" "")
    
    ;; Criar letra
    (command "_.TEXT" "_J" "_MC" "0,0" "1.5" "0" letter)
    
    ;; Ajustar zoom
    (command "_.ZOOM" "_E")
    
    ;; Criar slide
    (command "_.MSLIDE" (strcat "LETTER_" letter))
    
    (princ (strcat "\nSlide criado: LETTER_" letter))
  )
  
  (setvar "CMDECHO" old_cmdecho)
  (setvar "OSMODE" old_osmode)
  
  (princ "\n\nTodas as letras criadas! Use SLIDELIB para criar a biblioteca.")
  (princ)
)

;; Instruções para o usuário
(defun c:HELP_SLIDES ()
  (princ "\n==========================================")
  (princ "\nCRIAÇÃO DE SLIDES PARA WORDLE")
  (princ "\n==========================================")
  (princ "\nComandos disponíveis:")
  (princ "\n1. CREATE_LETTER_SLIDES - Cria slides A-Z (branco)")
  (princ "\n2. CREATE_COLORED_LETTER_SLIDES - Cria slides A-Z em 4 cores")
  (princ "\n3. CREATE_SLIDE_LIST - Cria arquivo de lista para SLIDELIB")
  (princ "\n4. CREATE_SIMPLE_LETTERS - Versão rápida apenas letras brancas")
  (princ "\n")
  (princ "\nPASSO A PASSO:")
  (princ "\n1. Execute CREATE_COLORED_LETTER_SLIDES")
  (princ "\n2. Execute CREATE_SLIDE_LIST")
  (princ "\n3. No prompt do AutoCAD, digite: SLIDELIB Wordle")
  (princ "\n4. Quando pedir, digite: < slide_list.txt")
  (princ "\n5. Pressione Enter em linha vazia para finalizar")
  (princ "\n")
  (princ "\nO arquivo Wordle.slb será criado na pasta atual.")
  (princ "\n==========================================")
  (princ)
)

;; Carregar mensagem
(princ "\nScript CREATE_LETTER_SLIDES.lsp carregado.")
(princ "\nDigite HELP_SLIDES para ver instruções.")
(princ)