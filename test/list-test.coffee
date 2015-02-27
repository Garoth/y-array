chai      = require('chai')
expect    = chai.expect
should    = chai.should()
sinon     = require('sinon')
sinonChai = require('sinon-chai')
_         = require("underscore")

chai.use(sinonChai)

Y = require "../../yjs/lib/y"
Y.List = require "../lib/y-list"

Connector = require "../../y-test/lib/y-test.coffee"

TestSuite = require "../../yjs/test/object-test"

class ListTest extends TestSuite

  constructor: (suffix)->
    super suffix, Y

  type: "ListTest"

  makeNewUser: (userId)->
    conn = new Connector userId
    new Y conn

  initUsers: (u)->
    u.val("ListTest",new Y.List())

  getRandomRoot: (user_num)->
    @users[user_num].val("ListTest")

  getContent: (user_num)->
    @users[user_num].val("ListTest").val()

describe "List Test", ->
  @timeout 500000

  beforeEach (done)->
    @yTest = new ListTest()
    done()

  it "can handle many engines, many operations, concurrently (random)", ->
    console.log "" # TODO
    @yTest.run()

  it "simple multi-char insert", ->
    u = @yTest.users[0].val("ListTest")
    u.insertContents 0, ['a','b','c']
    u = @yTest.users[1].val("ListTest")
    u.insert 0, 'x'
    u.insertContents 1, ['y', 'z']
    @yTest.compareAll()
    u.delete 0, 1
    @yTest.compareAll()
    expect(u.val().join("")).to.equal("bcxyz")

  it "Observers work on shared List (insert type observers, local and foreign)", ->
    u = @yTest.users[0].val("ListTest",new Y.List("my awesome List".split(""))).val("ListTest")
    @yTest.flushAll()
    last_task = null
    observer1 = (changes)->
      expect(changes.length).to.equal(1)
      change = changes[0]
      expect(change.type).to.equal("insert")
      expect(change.object).to.equal(u)
      expect(change.value).to.equal("a")
      expect(change.position).to.equal(1)
      expect(change.changedBy).to.equal('0')
      last_task = "observer1"
    u.observe observer1
    u.insert 1, "a"
    expect(last_task).to.equal("observer1")
    u.unobserve observer1

    observer2 = (changes)->
      expect(changes.length).to.equal(1)
      change = changes[0]
      expect(change.type).to.equal("insert")
      expect(change.object).to.equal(u)
      expect(change.value).to.equal("x")
      expect(change.position).to.equal(0)
      expect(change.changedBy).to.equal('1')
      last_task = "observer2"
    u.observe observer2
    v = @yTest.users[1].val("ListTest")
    v.insert 0, "x"
    @yTest.flushAll()
    expect(last_task).to.equal("observer2")
    u.unobserve observer2

  it "Observers work on shared List (delete type observers, local and foreign)", ->
    u = @yTest.users[0].val("ListTest",new Y.List("my awesome List".split(""))).val("ListTest")
    @yTest.flushAll()
    last_task = null
    observer1 = (changes)->
      expect(changes.length).to.equal(1)
      change = changes[0]
      expect(change.type).to.equal("delete")
      expect(change.object).to.equal(u)
      expect(change.position).to.equal(1)
      expect(change.length).to.equal(1)
      expect(change.changedBy).to.equal('0')
      last_task = "observer1"
    u.observe observer1
    u.delete 1, 1
    expect(last_task).to.equal("observer1")
    u.unobserve observer1

    observer2 = (changes)->
      expect(changes.length).to.equal(1)
      change = changes[0]
      expect(change.type).to.equal("delete")
      expect(change.object).to.equal(u)
      expect(change.position).to.equal(0)
      expect(change.length).to.equal(1)
      expect(change.changedBy).to.equal('1')
      last_task = "observer2"
    u.observe observer2
    v = @yTest.users[1].val("ListTest")
    v.delete 0, 1
    @yTest.flushAll()
    expect(last_task).to.equal("observer2")
    u.unobserve observer2

  it "can handle many engines, many operations, concurrently (random)", ->
    console.log("testiy deleted this TODO:dtrn")
    @yTest.run()

  it "handles double-late-join", ->
    test = new ListTest("double")
    test.run()
    @yTest.run()
    u1 = test.users[0]
    u2 = @yTest.users[1]
    ops1 = u1._model.HB._encode()
    ops2 = u2._model.HB._encode()
    u1._model.engine.applyOp ops2, true
    u2._model.engine.applyOp ops1, true
    @yTest.compare u1, u2


module.exports = ListTest






















