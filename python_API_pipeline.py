import requests
import json
import base64
import pandas as pd
import matplotlib as mt

############################################
## AUTHORIZATION PIPELINE FOR SPOTIFY API ##
############################################

#Requesting access to the spotify web API
client_id = #YOUR CLIEND ID
client_secret = #YOUR CLIENT SECRET

auth_header_b64 = base64.b64encode(f'{client_id}:{client_secret}'.encode('ascii'))
auth_header = auth_header_b64.decode('ascii')

req_header =  {'Authorization' : f'Basic {auth_header}'}
payload = {"grant_type": "client_credentials"}
url = "https://accounts.spotify.com/api/token"
resp = requests.post(url, headers = req_header, data = payload)
token = resp.json()

token['access_token']

#Defining header with access token
header = {
"Accept": "application/json",
"Content-Type": "application/json",
"Authorization": f"Bearer {token['access_token']}"
}

########################
## DEFINING API CALLS ##
########################

def tracks_albums(album_id):
    varb = requests.get(f"https://api.spotify.com/v1/albums/{album_id}/tracks?limit=20", headers = header)
    raw = pd.DataFrame(varb.json()['items'])
    varb = raw[['track_number']]
    varb['track_id'] = raw['id']
    #Guardando o nome do album:
    varb['album_id'] = album_id
    return varb

#Função para pegar lista de musicas de cada album
def album_to_track(id_artista):
    album_dos_artistas = albums(id_artista)
    tracks = map(tracks_albums, album_dos_artistas['id'])
    oi = map(lambda dt : dt.merge(album_dos_artistas, left_on = 'album_id', right_on = 'id'), tracks)
    return pd.concat(oi).drop(columns = ['id'])

#Getting global audio analysis for a single track
def audio_analysis(track):
    oi = requests.get(f"https://api.spotify.com/v1/audio-features/{track}", headers = header).json()
    return oi

#Function receives an artist and returns all of his albuns with global analysis for each track within each album.
def describing_tracks(artist):
    try:
        tracks_artists = album_to_track(artist)
        tracks = map(audio_analysis, tracks_artists['track_id'])
        tracks = pd.DataFrame(tracks)
        oi = tracks.merge(tracks_artists, left_on = "id", right_on = 'track_id').drop(columns = ['id'])
    except:
        return {}
    return oi.drop(columns = ['analysis_url', 'track_href', 'uri'])

#Define query
def query_genre(genero):
    oi = requests.get(f"https://api.spotify.com/v1/search?q=genre:{genero}&type=artist&limit=50", headers = header).json()
    oi = pd.DataFrame(oi['artists']['items'])
    return oi

#Get many artists from different genres
def many_artists(genre: str):
    artistas = []
    for i in genre:
        try:
            artistas = artistas + list(query_genre(i)['id'])
        except:
            continue
    artistas = list(dict.fromkeys(artistas)) #without repeated artists
    return artistas

#Definindo api para busca de info low-level
def low_level(track):
    return requests.get(f"https://api.spotify.com/v1/audio-analysis/{track}", headers = header).json()

##################################
## DEFINING ARTISTS OF INTEREST ##
##################################

artists = ['Bruno Mangueira', 'Pedro de Alcântara', 'Giovani Malini', 'Gabriel Ruy', 'Brasilidade Geral', 'Chryzo Rocha', 'Bruno Santos', 'Gean Pierre', 'Wanderson Lopez']  
ids = ['03RqVUN4boTfVwYtfC7oyR', '2SFL3Vf8W5rnkNhxAfzVZw', '0nHct9WwoM7p6X2z9YiJle', '3lmJAyzVpHiaopfPPB6Npb', '42hyGIhMAhr9rl8kTWy4g8', '6QCrBlMRv0UnMhdgjJRs2c', '0LG8WqHOGcDsk7EB2zYogH', '39WI2UnxM1GrcGIzNX0GKN', '6KyPrxjeVXFiuFnMdFgVGL']

###########################
## CALLING THE FUNCTIONS ##
###########################

lista_final = []
for i in range(len(artists)):
    oi = describing_tracks(ids[i])
    oi['artista'] = artists[i]
    lista_final.append(oi)

final = pd.concat(lista_final)

#Getting low-level information
b2 = []
for i in list(final['track_id']):
    raw = pd.DataFrame(low_level(i)['sections'])
    raw['track_id'] = i
    b2.append(raw)