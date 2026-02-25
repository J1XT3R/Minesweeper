import de.bezier.guido.*;
public static final int NUM_ROWS = 24;
public static final int NUM_COLS = 24;
public static final int NUM_MINES = 60;
public static final int WINDOW_W = 720;
public static final int WINDOW_H = 720;
private MSButton[][] buttons;
private ArrayList<MSButton> mines = new ArrayList<MSButton>();
private boolean gameOver = false;
private boolean won = false;
private boolean minesPlaced = false;
private long gameStartTime = 0;
private String gameOverMessage = null;
private int gameOverTimeSeconds = 0;

void setup ()
{
    size(WINDOW_W, WINDOW_H);
    textAlign(CENTER, CENTER);
    
    Interactive.make( this );
    
    buttons = new MSButton[NUM_ROWS][NUM_COLS];
    for (int r = 0; r < NUM_ROWS; r++) {
        for (int c = 0; c < NUM_COLS; c++) {
            buttons[r][c] = new MSButton(r, c);
        }
    }
    Interactive.add(new PopupOverlay());
    Interactive.add(new RetryButton());
}

public void setMines(int safeRow, int safeCol)
{
    mines.clear();
    while (mines.size() < NUM_MINES) {
        int row = (int)(Math.random() * NUM_ROWS);
        int col = (int)(Math.random() * NUM_COLS);
        boolean isSafe = (row == safeRow && col == safeCol);
        if (!isSafe) {
            for (int dr = -1; dr <= 1 && !isSafe; dr++) {
                for (int dc = -1; dc <= 1; dc++) {
                    if (row == safeRow + dr && col == safeCol + dc) {
                        isSafe = true;
                        break;
                    }
                }
            }
        }
        if (!isSafe && !mines.contains(buttons[row][col])) {
            mines.add(buttons[row][col]);
        }
    }
}

public void draw ()
{
    background(192);
    if (!won && isWon()) {
        won = true;
        displayWinningMessage();
    }
}

private void drawGameOverPopup()
{
    int popupW = 320;
    int popupH = 180;
    int cx = width / 2;
    int cy = height / 2;
    int x = cx - popupW/2;
    int y = cy - popupH/2;
    fill(0, 0, 0, 180);
    noStroke();
    rect(0, 0, width, height);
    fill(240);
    stroke(80);
    strokeWeight(2);
    rect(x, y, popupW, popupH);
    noStroke();
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(28);
    text(gameOverMessage, cx, cy - 35);
    textSize(18);
    text("Time: " + gameOverTimeSeconds + " seconds", cx, cy);
    fill(220);
    stroke(100);
    rect(cx - 50, cy + 45, 100, 36);
    fill(0);
    noStroke();
    textSize(18);
    text("Retry", cx, cy + 63);
}

public void resetGame()
{
    gameOver = false;
    won = false;
    gameOverMessage = null;
    minesPlaced = false;
    mines.clear();
    for (int r = 0; r < NUM_ROWS; r++) {
        for (int c = 0; c < NUM_COLS; c++) {
            MSButton b = buttons[r][c];
            b.setClicked(false);
            b.setFlagged(false);
            b.setLabel("");
        }
    }
}

private class PopupOverlay {
    public float x = 0;
    public float y = 0;
    public float width = WINDOW_W;
    public float height = WINDOW_H;
    public void draw() {
        if (gameOverMessage != null) {
            drawGameOverPopup();
        }
    }
}

private class RetryButton {
    public float x = WINDOW_W/2 - 50;
    public float y = WINDOW_H/2 + 45;
    public float width = 100;
    public float height = 36;
    public boolean isInside(float mx, float my) {
        return gameOverMessage != null && mx >= x && mx <= x + width && my >= y && my <= y + height;
    }
    public void draw() {
        if (gameOverMessage != null) {
            fill(220);
            stroke(100);
            strokeWeight(1);
            rect(x, y, width, height);
            noStroke();
            fill(0);
            textAlign(CENTER, CENTER);
            textSize(18);
            text("Retry", x + width/2, y + height/2);
        }
    }
    public void mousePressed(float mx, float my) {
        if (gameOverMessage != null && isInside(mx, my)) {
            resetGame();
        }
    }
}

public boolean isWon()
{
    for (int r = 0; r < NUM_ROWS; r++) {
        for (int c = 0; c < NUM_COLS; c++) {
            MSButton b = buttons[r][c];
            if (mines.contains(b) && !b.isFlagged()) return false;
            if (!mines.contains(b) && !b.isClicked()) return false;
        }
    }
    return true;
}
public void displayLosingMessage()
{
    gameOver = true;
    for (MSButton m : mines) {
        m.setClicked(true);
    }
    gameOverMessage = "You Lose!";
    gameOverTimeSeconds = (int)((millis() - gameStartTime) / 1000);
}
public void displayWinningMessage()
{
    gameOver = true;
    gameOverMessage = "You Win!";
    gameOverTimeSeconds = (int)((millis() - gameStartTime) / 1000);
}
public boolean isValid(int r, int c)
{
    return r >= 0 && r < NUM_ROWS && c >= 0 && c < NUM_COLS;
}
public int countMines(int row, int col)
{
    int numMines = 0;
    for (int r = row - 1; r <= row + 1; r++) {
        for (int c = col - 1; c <= col + 1; c++) {
            if ((r != row || c != col) && isValid(r, c) && mines.contains(buttons[r][c])) {
                numMines++;
            }
        }
    }
    return numMines;
}
public class MSButton
{
    private int myRow, myCol;
    private float x,y, width, height;
    private boolean clicked, flagged;
    private String myLabel;
    
    public MSButton ( int row, int col )
    {
        width = (float)WINDOW_W/NUM_COLS;
        height = (float)WINDOW_H/NUM_ROWS;
        myRow = row;
        myCol = col; 
        x = myCol*width;
        y = myRow*height;
        myLabel = "";
        flagged = clicked = false;
        Interactive.add( this );
    }

    public void mousePressed () 
    {
        if (gameOver) return;
        if (mouseButton == RIGHT) {
            if (!minesPlaced) return;
            flagged = !flagged;
            clicked = !flagged;
        } else {
            if (!minesPlaced) {
                setMines(myRow, myCol);
                minesPlaced = true;
                gameStartTime = millis();
            }
            if (flagged) return;
            clicked = true;
            if (mines.contains(this)) {
                displayLosingMessage();
            } else {
                int n = countMines(myRow, myCol);
                if (n > 0) {
                    setLabel(n);
                } else {
                    for (int r = myRow - 1; r <= myRow + 1; r++) {
                        for (int c = myCol - 1; c <= myCol + 1; c++) {
                            if (isValid(r, c) && !buttons[r][c].isClicked() && !buttons[r][c].isFlagged()) {
                                buttons[r][c].mousePressed();
                            }
                        }
                    }
                }
            }
        }
    }
    public void draw () 
    {    
        noStroke();
        float cx = x + width/2;
        float cy = y + height/2;
        
        if (!clicked) {
            fill(192);
            rect(x, y, width, height);
            fill(255);
            rect(x, y, width - 1, 1);
            rect(x, y, 1, height - 1);
            fill(128);
            rect(x + 1, y + height - 1, width - 1, 1);
            rect(x + width - 1, y + 1, 1, height - 1);
            if (flagged) {
                drawFlag(x, y, width, height);
            }
        } else {
            fill(189);
            rect(x + 1, y + 1, width - 1, height - 1);
            if (mines.contains(this)) {
                drawMine(cx, cy, min(width, height) * 0.35f);
            } else if (!myLabel.equals("")) {
                setNumberColor(myLabel);
                textAlign(CENTER, CENTER);
                textSize(min(width, height) * 0.6f);
                text(myLabel, cx, cy);
            }
        }
    }
    
    private void setNumberColor(String label) {
        if (label.length() != 1) { fill(0); return; }
        switch (label.charAt(0)) {
            case '1': fill(0, 0, 255); break;
            case '2': fill(0, 128, 0); break;
            case '3': fill(255, 0, 0); break;
            case '4': fill(0, 0, 128); break;
            case '5': fill(128, 0, 0); break;
            case '6': fill(0, 128, 128); break;
            case '7': fill(0, 0, 0); break;
            case '8': fill(128, 128, 128); break;
            default: fill(0);
        }
    }
    
    private void drawFlag(float px, float py, float w, float h) {
        float pad = min(w, h) * 0.2f;
        float poleW = w * 0.15f;
        float poleH = h - 2*pad;
        fill(0);
        rect(px + w/2 - poleW/2, py + pad, poleW, poleH);
        fill(255, 0, 0);
        noStroke();
        triangle(px + w/2, py + pad + 2,
                 px + w/2, py + h/2,
                 px + w - pad, py + pad + poleH/3);
    }
    
    private void drawMine(float cx, float cy, float r) {
        fill(0);
        ellipse(cx, cy, r*2, r*2);
        fill(80);
        ellipse(cx - r*0.2f, cy - r*0.2f, r*0.4f, r*0.4f);
        stroke(0);
        strokeWeight(max(1, r/8));
        for (int i = 0; i < 8; i++) {
            float a = i * TWO_PI/8;
            line(cx + cos(a)*r*0.6f, cy + sin(a)*r*0.6f,
                 cx + cos(a)*r*1.1f, cy + sin(a)*r*1.1f);
        }
        noStroke();
    }
    public void setLabel(String newLabel)
    {
        myLabel = newLabel;
    }
    public void setLabel(int newLabel)
    {
        myLabel = ""+ newLabel;
    }
    public boolean isFlagged()
    {
        return flagged;
    }
    public boolean isClicked()
    {
        return clicked;
    }
    public void setClicked(boolean val)
    {
        clicked = val;
    }
    public void setFlagged(boolean val)
    {
        flagged = val;
    }
}
