from similarity_judge import SimilarityCheck
import flask


"""
POST -> Content-Type: application/json
@:parameter
comment    -> 新規コメント
comment_id -> 修正されたコメントならばidをいれる

@:return comments:
reply_num  -> リプライがある: コメントID, リプライがない: 400

"""
app = flask.Flask(__name__)


@app.route("/api.soco.com/v1/similarity", methods=["POST"])
def similarity_insert():
    comments_json = flask.request.json.items()
    comment_id = flask.request.args.get('id', default=None)
    comment = flask.request.args.get('comment')

    logic = SimilarityCheck(comments_json)
    reply_num = logic.return_api(comment_id, comment)

    try:
        good_request = flask.jsonify(
            {
                'code': 200,
                'comment_id': reply_num
            }
        )

        return good_request
    except Exception as exception_data:
        bad_request = flask.jsonify(
            {
                'code': 400,
                'msg': 'Bad Request',
                'status': exception_data
            }
        )

        return bad_request


if __name__ == "__main__":
    app.run()
