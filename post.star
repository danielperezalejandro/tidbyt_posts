"""
Applet: Post
Summary: Visualizar post
Description: Visualizar post de un apai.
Author: danielperezalejandro
"""

load("render.star", "render")
load("schema.star", "schema")
load("time.star", "time")
load("http.star", "http")
load("encoding/base64.star", "base64")

USER_DEFAULT=""
DEFAULT_DATE=str(time.now())
USER_MAIN=""



def main(config):
    usuario = config.str("who", USER_DEFAULT)
    inicio=config.str("follower", USER_MAIN)
    
    #muestra lo posts d eun usuario en concreto
    if usuario!="":
        
        POST_URL = "http://localhost:3900/api/getuserposts/{}".format(usuario)
        rep = http.get(POST_URL)
        
        if rep.status_code != 200:
            fail("Coindesk request failed with status %d", rep.status_code)
        text="no hay usuarios"    

        posts = rep.json()["post"]  # Acceder a la lista de posts en el diccionario
        
        postMostrar=[]
        textos=""

        for post in posts:
            text = str(post["text"])  # Acceder al valor de "text" en cada post
            user= str(post["user"])
            date=str(post["date"])

            post_formatted_text = render.WrappedText(text)
            # Agregar el texto formateado a la lista de posts a mostrar
            postMostrar.append(post_formatted_text)
            # Agregar un espacio entre los posts
            postMostrar.append(render.Box(width=64, height=8))

        return render.Root(
            delay = 100,
            show_full_animation = True,
            child = render.Column(
                children = [
                    render.Box(
                        width = 64,
                        height = 8,
                        padding = 0,
                        color="#000080",
                        child = render.Text(user, offset = 0),
                    ),
                    render.Marquee(
                        height = 24,
                        scroll_direction = "vertical",
                        offset_start = 24,
                        child =
                            render.Column(
                                main_align = "space_between",
                                children = render_article(posts),
                            ),
                    ),
                ],
            ),
        )
    # muestra lo posts de un usuario en concreto
    elif inicio!="":
        FOLLOWER_URL="http://localhost:3900/api/{}/followingPosts".format(inicio)
        rep = http.get(FOLLOWER_URL)

        if rep.status_code != 200:
            fail("Coindesk request failed with status %d", rep.status_code)
        text="no hay usuarios"
      

        posts = rep.json()["posts"]  # Acceder a la lista de posts en el diccionario
        
        postMostrar=[]
        for post in posts:
            text = str(post["text"])  # Acceder al valor de "text" en cada post
            user= str(post["user"])
            date=str(post["date"])

            post_formatted_text = render.WrappedText(text)
            # Agregar el texto formateado a la lista de posts a mostrar
            postMostrar.append(post_formatted_text)
            # Agregar un espacio entre los posts
            postMostrar.append(render.Box(width=64, height=8))

        return render.Root(
            delay = 100,
            show_full_animation = True,
            child = render.Column(
                children = [
                    render.Box(
                        width = 64,
                        height = 8,
                        padding = 0,
                        color="#000080",
                        child = render.Text("SIGUIENDO", offset = 0),
                    ),
                    render.Marquee(
                        height = 24,
                        scroll_direction = "vertical",
                        offset_start = 24,
                        child =
                            render.Column(
                                main_align = "space_between",
                                children = render_inicio(posts),
                            ),
                    ),
                ],
            ),
        )


def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "who",
                name = "Usuario",
                desc = "Introduce el usuario para ver sus posts",
                icon = "user",
            ),
            schema.Text(
                id = "follower",
                name = "Inicio",
                desc = "Introduce tu usuario",
                icon = "lock",
            ),
        ],
    )

def obtnerFormatoFecha(fecha):
    fecha=fecha.split(" ")
    fecha=fecha[0]
    fecha=fecha.split("T")
    fecha=fecha[0]
    year,month,day=fecha.split("-")
    fecha=fecha.split("-")
    texto_fecha=day+"-"+month+"-"+year
    return texto_fecha

#Crea el render de los posts de un usuario
def render_article(posts):
    news_text = []
    for post in posts:
        news_text.append(render.WrappedText(obtnerFormatoFecha(post["date"]),color="#B0B0B0"))
        news_text.append(render.WrappedText(post["text"],font="tom-thumb",color="#CCCCFF"))
        news_text.append(render.Box(width = 64, height = 8))
    

    return (news_text)
#Crea el render de los posts del inicio de un usuario
def render_inicio(posts):
    news_text = []
    for post in posts:
        news_text.append(render.WrappedText(obtnerFormatoFecha(post["date"]),color="#B0B0B0"))
        news_text.append(render.WrappedText(post["user"].upper(),font="tom-thumb"))
        news_text.append(render.WrappedText(post["text"].upper(),font="tom-thumb",color="#CCCCFF"))
        
        news_text.append(render.Box(width = 64, height = 8))
    

    return (news_text)