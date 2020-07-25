library(data.table)
library(dplyr)
library(ggplot2)
library(gridExtra)
library(scales)

setwd("C:/Users/Lenovo/Desktop/mpb_jazz/dado")

dados = 
  fread("capixabas.csv") 

#Descritivas
length(unique(dados$album_id)) #número de albums
length(unique(dados$track_id)) #número de tracks
length(unique(dados$artista)) #número de albums

plot<- plyr::ddply(dados, c('artista'), summarise,
                   track    = length(unique(track_id)),
                   album = length(unique(album_id))
)
mean(plot$track)


dados$energy = rescale(dados$energy, to = c(0, 1))
dados$loudness_x = rescale(dados$loudness_x, to = c(0, 1)) 
dados$tempo_x = rescale(dados$tempo_x, to = c(0, 1))

plot<- plyr::ddply(dados, c('artista'), summarise,
                   Energia    = mean(energy),
                   Volume = abs(mean(loudness_x)),
                   Andamento   = mean(tempo_x)
)

um =
ggplot(data = filter(plot, plot$artista != 'Sepultura'), aes(x = reorder(artista, Energia), y = Energia, fill=Energia))+
  geom_bar(stat="identity") +
  ylab('Energia')+
  xlab('')+
  ggtitle('RANKING DE ENERGIA POR TRACK')+
  scale_fill_continuous(low="blue", high="red") +
  coord_flip()+
#  scale_fill_manual(values=c("red", "grey50", "grey50", "grey50", "grey50", "grey50", "grey50", "grey50", "grey50", "grey50", "grey50", "grey50", "grey50", "grey50"))+
  theme(legend.position = "none")

dois = 
ggplot(data = plot, aes(x = reorder(artista, Energia), y = Energia, fill=Energia))+
  geom_bar(stat="identity") +
  ylab('Energia')+
  xlab('')+
  ggtitle('RANKING DE ENERGIA POR TRACK - \nCom controle')+
  scale_fill_continuous(low="blue", high="red") +
  coord_flip()+
  #  scale_fill_manual(values=c("red", "grey50", "grey50", "grey50", "grey50", "grey50", "grey50", "grey50", "grey50", "grey50", "grey50", "grey50", "grey50", "grey50"))+
  theme(legend.position = "none")

plot<- plyr::ddply(dados, c('artista'), summarise,
                   N    = length(key_confidence),
                   confidence = abs(mean((key_confidence), na.rm = TRUE)),
                   sd   = sd(key_confidence, na.rm = TRUE)
)

dados =
  split(dados, dados$track_id)

for(i in 1:length(dados)){

  for(j in 1:length(dados[i])){
    dados[[i]]$troca_key = length(unique(dados[[i]]$key_x)) 
    dados[[i]]$troca_ts = length(unique(dados[[i]]$time_signature_x))
    dados[[i]]$certeza_ts = mean(dados[[i]]$key_confidence)
    dados[[i]]$certeza_key = mean(dados[[i]]$time_signature_confidence)
    
  }
}

dados =
  dplyr::bind_rows(dados)

plot<- plyr::ddply(filter(dados, dados$artista != 'Sepultura'), c('artista'), summarise,
                   troca_key = mean(troca_key),
                   troca_ts = mean(troca_ts),
                   certeza_key = mean(certeza_key),
                   certeza_ts = mean(certeza_ts),
                   simplicity = certeza_key*certeza_ts
)

tres =
ggplot(data = plot, aes(x = reorder(artista, troca_key), y = troca_key, fill = troca_key))+
  geom_bar(stat = 'identity')+
  ylab('Número de modulações')+
  xlab('')+
  ggtitle('MODULAÇÃO POR TRACK')+
  coord_flip()+
  scale_fill_continuous(low="blue", high="red") +
  theme(legend.position = "none")

quatro =
ggplot(data = plot, aes(x = reorder(artista, certeza_key), y = certeza_key, fill = certeza_key))+
  geom_bar(stat = 'identity')+
  ggtitle('CLAREZA TONAL')+
  ylab('')+
  xlab('')+
  coord_flip()+
  scale_fill_continuous(low="blue", high="red") + 
  theme(legend.position = "none")

cinco =
  ggplot(data = plot, aes(x = reorder(artista, troca_ts), y = troca_ts, fill = troca_ts))+
  geom_bar(stat = 'identity')+
  ylab('Número de métricas')+
  xlab('')+
  coord_flip()+
  ggtitle('MUDANÇA DE MÉTRICA POR TRACK')+
  scale_fill_continuous(low="blue", high="red") +
  theme(legend.position = "none")

seis =
ggplot(data = plot, aes(x = reorder(artista, certeza_ts), y = certeza_ts, fill = certeza_ts))+
  geom_bar(stat = 'identity')+
  ggtitle('CLAREZA MÉTRICA')+
  ylab('')+
  xlab('')+
  coord_flip()+
  scale_fill_continuous(low="blue", high="red") +
  theme(legend.position = "none")


##################
## SIMPLICIDADE ##
##################
sete = 
ggplot(data = plot, aes(x = reorder(artista, simplicity), y = simplicity, fill = simplicity))+
  geom_bar(stat = 'identity')+
  ylab('')+
  xlab('')+
  coord_flip()+
  ggtitle('SIMPLICIDADE')+
  scale_fill_continuous(low="blue", high="red") +
  theme(axis.text.x = element_text(angle = 90), 
        legend.position = "none")


um 

#O primeiro ranking que nós mostramos é o ranking de energia.
#Segundo o API do spotify, esse parâmetro é calculado com base 
#nos níveis volume, de ruído do sinal acústico.
#É interessante avaliar como esses músicos 
#se organizam energéticamente, mas também é legal ter um ponto de referência
# No gráfico abaixo eu ploto o sepultura, só para nós termos uma ideia
# do nível de energia da MPB capixaba em relação ao heavy metal, por exemplo.

library("gridExtra")
cinco_seis = grid.arrange(cinco, seis, 
             ncol = 2)
um
dois
tres
quatro
cinco
seis
sete

#
ggsave(um, filename = "1.png", dpi = 1200,
       width = 6, height = 4.5, units = "in")

ggsave(dois, filename = "2.png", dpi = 1200,
       width = 6, height = 4.5, units = "in")

ggsave(tres, filename = "3.png", dpi = 1200,
       width = 6, height = 4.5, units = "in")

ggsave(quatro, filename = "4.png", dpi = 1200,
       width = 6, height = 4.5, units = "in")

ggsave(cinco_seis, filename = "5.png", dpi = 1200,
       width = 8, height = 4.5, units = "in")

#ggsave(seis, filename = "6.png", dpi = 1200,
#       width = 6, height = 4.5, units = "in")

ggsave(sete, filename = "7.png", dpi = 1200,
       width = 6, height = 4.5, units = "in")




#Heatmaps
library(cluster)

plot<- plyr::ddply(dados, c('track_number'), summarise,
                   energy = mean(energy),
                   loudness = mean(loudness_x),
                   valence = mean(valence),
                   danceability = mean(danceability)
)

heatmap(as.matrix(daisy(plot[, 2:ncol(plot)], stand = T)), Colv = NA, Rowv = NA, scale="row")

heatmap(as.matrix(daisy(dados[, 3:12], stand = T)), Colv = NA, Rowv = NA, scale="row")

daisy(dados[, 3:12], stand = T)

##################
## Track number ##
##################

plot<- plyr::ddply(dados, c('track_number', 'artista', 'album_id'), summarise,
                   N    = length(energy*loudness_x*tempo_x*consistencia_tepo*troca_key),
                   complexidade = abs(mean((energy*loudness_x*tempo_x*consistencia_tepo*troca_key), na.rm = TRUE)),
                   sd   = sd(energy*loudness_x*tempo_x*consistencia_tepo*troca_key, na.rm = TRUE)
)

ggplot(data = filter(plot, artista == 'Trio corrente'), aes(x = as.factor(track_number), y = complexidade))+
  facet_wrap(~artista+album_id)+
  geom_col()
