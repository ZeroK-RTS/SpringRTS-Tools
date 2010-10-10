import logging
from django.utils import simplejson
from google.appengine import webapp
class Listener(webapp.RequestHandler):
  def post(self):
    payload = simplejson.loads(self.request.body)
    for revision in payload["revisions"]:
      logging.info("Project %s, revision %s contains %s paths",
                   payload["project_name"],
                   revision["revision"],
                   revision["path_count"])
